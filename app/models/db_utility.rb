# ----------------------------------------------
# --  Database utility for LiteRail project   --
# --  Execute to reset database with data     --
# --  from default.sql                        --
# --  Created by: Michael Parlato             --
# ----------------------------------------------
require_relative 'db_connection'


def reset
  DBConnection.reset
end
