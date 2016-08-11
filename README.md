# LiteRail README

## Overview:
A lite version of Rails with ActiveRecord.

## Creating a new app with LiteRail:
### Creating models
* Navigate to the home directory of your app (containing app/, lib/, bin/, etc.)
* To set up the default database, execute the following from terminal:
```
ruby 'app/model/db_utility.rb'
```
* That will set up a database with one table, "users". Check it out! Open
your database with:
```
sqlite3 app/default.db
```
and check out the tables!

* To change the default database schema and seed data, edit your
'app/default.sql'. Every time you run the db_utility, the database will
be reset with the seed data. To establish a connection to the database
within a file, simply:
```
require 'app/model/db_connection.rb'
```
* Now, let's add some new tables. Run the following command from terminal, within the app's home directory:
```
ruby -r "./app/models/db_utility.rb" -e "create 'model_name'"
```
For instance, if you wish to create a new 'comment' model with an associated 'comments' table in the database, then your model_name would be 'comment'. Now, let's say we want to create a table with a column or two in it. Simply tack on each addition column (along with its type and constraints) in an array as the second parameter to #create:
```
ruby -r "./app/models/db_utility.rb" -e "create('rating',['score INTEGER NOT NULL'])"
```
The above will create a new model called 'rating.rb' as well as a table called 'ratings' with both an ID and score, where the score is an integer that must be set at intialization.
