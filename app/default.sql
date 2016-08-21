
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  age INTEGER
);

INSERT INTO
  users (id, name, age)
VALUES
  (1, "Michael", 28), (2, "Jackie", 27);


CREATE TABLE comments (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  body TEXT
);

INSERT INTO
  comments (id, user_id, body)
VALUES
  (1, 1, "My first comment!");
