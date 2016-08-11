require_relative 'searchable'
require 'active_support/inflector'
require 'active_support/inflector'

# Phase IIIa
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
