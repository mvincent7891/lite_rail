# LiteRail README

## Overview:
A lite version of Rails with ActiveRecord. This README assumes a certain (>= intermediate) level of familiarity with the popular Ruby on Rails web development framework.

## Creating a new app with LiteRail:
### Creating models
* First download or clone this directory and rename the top directory with the name of your new app
* Navigate to the home directory of your app (containing app/, lib/, bin/, etc.)
* To set up the default database, execute the following from the terminal:
```
ruby 'app/model/db_utility.rb'
```
* That will set up a database with one table, "users". Check it out! Open your database with:
```
sqlite3 app/default.db
```
and check out the tables with:
```
.tables
```

* To change the default database schema and seed data, edit your 'app/default.sql'. Every time you run the db_utility, the database will be reset with the seed data in that file. To establish a connection to the database
within a ruby file, simply:
```
require 'app/model/db_connection.rb'
```
* Now, let's add some new tables. Run the following command from terminal, within the app's home directory:
```
ruby -r "./generate.rb" -e "model 'model_name'"
```
For instance, if you wish to create a new 'comment' model with an associated 'comments' table in the database, then your model_name would be 'comment'. Now, let's say we want to create a table with a column or two in it. Simply tack on each addition column (along with its type and constraints!) in an array as the second parameter to #model:
```
ruby -r "./generate.rb" -e "model('rating',['score INTEGER NOT NULL'])"
```
The above will create a new model called 'rating.rb' as well as a table called 'ratings' with both an ID and score, where the score is an integer that must be set at intialization.

### Creating controllers
* Looks like we're missing our users controller. Let's fix that. Pop back over to terminal and execute the following:
```
ruby -r "./generate.rb" -e "controller('users')"
```
That's it! The newly generated users controller lives in app/controllers along with the application controller, from which all controllers inherit. Now generate controllers for the rest of your models. Notice that when a controller is created, it only has access to the associated model.
```
require_relative 'app/controllers/application_controller'
require_relative 'app/models/user.rb'
...
```
If you need to access other models, just use associations or require them.
