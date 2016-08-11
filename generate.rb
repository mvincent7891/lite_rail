# ----------------------------------------------
# --  Generate utility for LiteRail project   --
# --  Created by: Michael Parlato             --
# ----------------------------------------------
require 'active_support/inflector'

def model(model_name, options = [])
  # prefer lower case and snake case for model names
  file_name = "app/models/#{model_name.downcase}.rb"
  f = File.new("#{file_name}", "w")
  model_name_cc = ActiveSupport::Inflector.camelize(model_name)
  model_string = <<-RUBY
    require_relative 'sql_object'

    class #{model_name_cc} < SQLObject
      # do not remove finalize - this sets column accessors
      finalize!
    end
  RUBY

  File.open(file_name, 'w') do |f|
    f.write(model_string)
    f.close
  end

  columns_string = options.join(', ')

  table_string = <<-SQL
\n
CREATE TABLE #{ActiveSupport::Inflector.pluralize(model_name.downcase)} (
  id INTEGER PRIMARY KEY,
  #{columns_string}
);
  SQL

  File.open('app/default.sql', 'a') do |f|
    f.write(table_string)
    f.close
  end

end

def controller(controller_name)
  # prefer lower case, plural and snake case for controller_name in method call
  controller_name_cc = ActiveSupport::Inflector.camelize(controller_name)
  model_name = ActiveSupport::Inflector.singularize(controller_name)
  controller_string = <<-RUBY
    require_relative './application_controller'
    require_relative '../models/#{model_name}.rb'

    class #{controller_name_cc}Controller < ApplicationController
    end
  RUBY

  file_name = "app/controllers/#{controller_name}_controller.rb"
  f = File.new("#{file_name}", "w")
  File.open(file_name, 'w') do |f|
    f.write(controller_string)
    f.close
  end


end
