require_relative 'db_connection'
require 'byebug'

module Searchable
  # def where(params)
  #   where_line = params.keys.map(&:to_s).map { |col| "#{col} = ?"}.join(' AND ')
  #   table_name = self.table_name
  #   sql_string = <<-SQL
  #     SELECT
  #       *
  #     FROM
  #       #{table_name}
  #     WHERE
  #       #{where_line}
  #   SQL
  #
  #   results = DBConnection.execute(sql_string, *params.values)
  #   return [] if results.empty?
  #   results.map { |obj| self.new(obj) }
  # end

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

  def to_a
    results = DBConnection.execute(def_query, *@params.values)
    return [] if results.empty?
    byebug
    results.map { |obj| @klass.new(obj) }
  end

end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end


class Cat < SQLObject
  finalize!
end
