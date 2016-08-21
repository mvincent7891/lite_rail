require_relative 'sql_object'
require_relative 'user'

class Comment < SQLObject
  # do not remove finalize - this sets column accessors
  finalize!
  belongs_to :user
end
