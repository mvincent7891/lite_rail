require_relative 'sql_object'
require_relative 'comment'

class User < SQLObject
  # do not remove finalize - this sets column accessors
  finalize!
  has_many :comments
end
