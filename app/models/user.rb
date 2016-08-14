require_relative 'sql_object'


class User < SQLObject
  # do not remove finalize - this sets column accessors
  finalize!
end
