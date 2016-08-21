require_relative './db_connection'
require 'active_support/inflector'


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

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    "#{self.class_name.underscore}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] ||  "#{name.to_s}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] ||  "#{self_class_name.to_s.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end

module Associatable

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method name do
      f_key = self.send(options.foreign_key)
      options.model_class.where(id: f_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method name do
      p_key = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => p_key)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @hash ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method name do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      id = self.send(self.class.assoc_options[through_name].foreign_key)
      sql_string = <<-SQL
      SELECT
      #{source_name.to_s}s.*
      FROM
      #{through_name.to_s}s
      JOIN
      #{source_name.to_s}s
      ON
      #{through_name.to_s}s.#{source_options.foreign_key.to_s} =
      #{source_name.to_s}s.id
      WHERE
      #{through_name.to_s}s.id = ?
      SQL

      DBConnection.execute(sql_string, id).map do |result_hash|
        source_options.model_class.new(result_hash)
      end
      .first
    end
  end

end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end

module Searchable

  def where(params)
    relation = Relation.new(self, self.table_name, params)
  end
end

class Relation
  attr_accessor :query, :klass, :table, :params, :values

  def initialize(klass, table, params)
    # may need to add predicate_builder - Does this construct where,
    # joins, left_outer_joins, etc???
    @klass = klass
    @table = table
    @params = params
    @values = params.values
    @query = def_query
  end

  def def_query
    where_line = @params.keys.map(&:to_s).map { |col| "#{col} = ?"}.join(' AND ')
    sql_string = <<-SQL
      SELECT
        *
      FROM
        #{@table}
      WHERE
        #{where_line}
    SQL
  end

  def where(params)
    klass = self
    table = self.table
    new_params = params.merge(self.params)
    Relation.new(klass, table, new_params)
  end

  def to_s
    where_line = @params.keys.map(&:to_s).map.with_index do |col, i|
      "#{col} = #{@params.values[i]}"
    end.join(' AND ')

    sql_string = <<-SQL
      SELECT
        *
      FROM
        #{@table}
      WHERE
        #{where_line}
    SQL
  end

  def first
    results = DBConnection.execute(def_query, *@params.values)
    return [] if results.empty?
    # results.map { |obj| obj.klass.new(obj) }
    @klass.parse_all(results)[0]
  end

  def to_a
    results = DBConnection.execute(def_query, *@params.values)
    return [] if results.empty?
    # results.map { |obj| obj.klass.new(obj) }
    @klass.parse_all(results)
  end

end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
