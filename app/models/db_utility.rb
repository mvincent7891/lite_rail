# ----------------------------------------------
# --  Database utility for LiteRail project   --
# --  Execute to reset database with data     --
# --  from default.sql                        --
# --  Created by: Michael Parlato             --
# ----------------------------------------------
require 'active_support/inflector'
require_relative 'db_connection'

DBConnection.reset

def create(model_name, options = [])
  # prefer lower case and snake case for model names
  file_name = "app/models/#{model_name.downcase}.rb"
  f = File.new("#{file_name}", "w")

  model_string = <<-RUBY
    require_relative 'sql_object'

    class User < SQLObject
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
CREATE TABLE #{model_name.downcase.pluralize} (
  id INTEGER PRIMARY KEY,
  #{columns_string}
);
  SQL

  File.open('app/default.sql', 'a') do |f|
    f.write(table_string)
    f.close
  end

end
