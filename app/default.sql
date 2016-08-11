
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  age INTEGER
);

INSERT INTO
  users (id, name, age)
VALUES
  (1, "Michael", 28), (2, "Jackie", 27);
