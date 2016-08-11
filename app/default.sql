----------------------------------------------
--  Database file for LiteRail project      --
--  Author must manually populate database  --
--  Created by: Michael Parlato             --
----------------------------------------------

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  age INTEGER
);

INSERT INTO
  users (id, name, age)
VALUES
  (1, "Michael", 28), (2, "James", 20), (3, "Jackie", 27);
