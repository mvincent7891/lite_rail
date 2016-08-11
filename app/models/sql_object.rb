require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  attr_accessor :table_name, :columns, :id
  def self.columns
    unless @columns
      result = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      @columns = result[0].map(&:to_sym)
    else
      @columns
    end
  end

  def self.finalize!

    columns.each do |col|
      # getter method
      define_method col do
        attributes[col]
      end

      # setter method
      define_method "#{col}=" do |arg|
        attributes[col] = arg
      end
    end
  end

  def self.table_name=(table_name)
    @table_name  = table_name
  end

  def self.table_name
    @table_name ||= "#{self.to_s}s".underscore
  end

  def self.all
    sql_string = <<-SQL
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(DBConnection.execute(sql_string))
  end

  def self.parse_all(results)
    results.map { |hash| self.new(hash) }
  end

  def self.find(id)
    sql_string = <<-SQL
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
       #{table_name}.id = #{id}
    SQL
    parse_all(DBConnection.execute(sql_string))[0] || nil
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless
        self.class.columns.include?(attr_name.to_sym)
      self.send("#{attr_name}=".to_sym, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col| self.send(col) }
  end

  def insert
    cols = self.class.columns
    col_names = cols.map(&:to_s).join(', ')
    q_marks = ("?"*(cols.length)).split('').join(', ')
    sql_string = <<-SQL
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{q_marks})
    SQL

    DBConnection.execute(sql_string, *attribute_values)
    self.attributes[:id] = DBConnection.last_insert_row_id
  end

  def update
    cols = self.class.columns
    set_line = cols.map(&:to_s).map { |col| "#{col} = ?"}.join(', ')
    sql_string = <<-SQL
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = #{self.attributes[:id]}
    SQL
    DBConnection.execute(sql_string, *attribute_values)

  end

  def save
    id.nil? ? insert : update
  end
end

class String
  def underscore
    self.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').downcase
  end
end
