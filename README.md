# LiteRail README

## Overview:
A lite version of Rails with a sprinkling of ActiveRecord (also lite). This README assumes a certain (>= intermediate) level of familiarity with the popular Ruby on Rails web development framework.

## Requirements
* Mac/Linux OS
* Ruby
* Pry
* sqlite3

## Creating a new app with LiteRail:
### Creating models
* First download or clone this repository and rename the top level directory with the name of your new app
* Navigate to the home directory of your app (containing app/, lib/, bin/, etc.)
* Run 'bundle install' from the terminal in the top level directory to get all the necessary gems
* To set up the default database, execute the following from the terminal:

```
ruby 'app/model/db_utility.rb'
```
That will set up a database with one table, "users". Check it out! Open the database with:

```
sqlite3 app/default.db
```
and check out the tables with:

```
.tables
```

To change the default database schema and seed data, edit your 'app/default.sql'. Every time you run the db_utility, the database will be reset with the seed data in that file. To establish a connection to the database
within a ruby file, simply:

```
require 'app/model/db_connection.rb'
```
Now, let's add some new tables. Run the following command from terminal, within the app's home directory:

```
ruby -r "./generate.rb" -e "model 'model_name'"
```
For instance, if you wish to create a new 'comment' model with an associated 'comments' table in the database, then your model_name would be 'comment'. Now, let's say we want to create a table with a column or two in it. Simply tack on each addition column (along with its type and constraints!) in an array as the second parameter to #model:

```
ruby -r "./generate.rb" -e "model('rating',['score INTEGER NOT NULL'])"
```
The above will create a new model called 'rating.rb' as well as a table called 'ratings' with both an ID and score, where the score is an integer that must be set at intialization.

### Creating controllers
Looks like we're missing our users controller. Let's fix that. Pop back over to terminal and execute the following:

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

### Controller-Model Interface

Now let's ses how the controller and model interact with each other. We're going to create a new user from within our controller.
* Open up your new controller model and overide the initialize method with a blank method (we'll need a server in the future when we initialize).
* OK - now write a #new method.
* This method should instantiate a new user with a name and age, then save the user.

Your users controller should look like this now:

```
require_relative './application_controller'
require_relative '../models/user.rb'

class UsersController < ApplicationController
  def initialize
  end

  def new
    @user = User.new(name: "James", age: 20)
    @user.save
  end
end
```
Great. Now how do we actually call this method? In some ideal future, our router would call the #new method when given some HTTP request. But for now, hop on over to the terminal and open pry. Let's load the controller, instantiate the controller, and call the #new method.

```
pry(main)> load 'app/controllers/users_controller.rb'
=> true
pry(main)> uc = UsersController.new
=> #<UsersController:0x007fa57aa48e78>
pry(main)> uc.new
=> 3

```

Hmm... did that work? Well, we have our lite version of object relational mapping - let's use it! Call User.all and see if you've successfully created a new user. What next? Well - let's see if we can do the same thing from the interwebs.

### Built-in Server

Go ahead and delete the initialize method you wrote into the users controller. Now, let's add some routes to our project. Open up your server.rb file and peruse the contents.
* First and foremost, we require the files LiteRail needs to achieve some basic functionality. I'll leave the details for your, um, reading pleasure.
* Next, you'll notice that application_controller.rb has been required. This allows us to build routes that call on the controller's methods. If you want to build routes to other controllers, require the source files here.
* Check out the router - we use regular expressions to define the path to a specific controller and method
* To test our LiteRail app, we use Rack's built in functions (::Builder.new and ::Server.start).

Great! Now, let's get the thing working. Open up terminal and run the following:

```
~.../LiteRail$ ruby server.rb
[2016-08-10 20:40:16] INFO  WEBrick 1.3.1
[2016-08-10 20:40:16] INFO  ruby 2.3.1 (2016-04-26) [x86_64-darwin15]
[2016-08-10 20:40:16] INFO  WEBrick::HTTPServer#start: pid=71490 port=3000
```

WEBrick is a freeby with Rack - a simple server for development. With that simple command, we're rolling. Open up your favorite web browser and navigate to localhost:3000/index - you should be greeted with LiteRail's default index page. What about the users controller we added? Add the controller to the required files in the server file, like so:

```
# require controllers here
require_relative 'app/controllers/application_controller.rb'
require_relative 'app/controllers/users_controller.rb'
...
```
Now what was it we wanted to do? Create a new user, right? Ok, well it would make sense if we just navigated to /users/new, wouldn't it? Let's create a route, and it will be so. Just uncomment the second get route in the server.rb file. How convenient :)

```
router = Router.new
router.draw do
  get Regexp.new("^/index$"), ApplicationController, :index
  get Regexp.new("^/users/new$"), UsersController, :new
end

```

### Error Handling

TODO: Add error for missing resource when trying to navigate to users/new before adding route.

Now let's give it a whirl. Head to localhost:3000/users/new.

```
No such file or directory @ rb_sysopen - app/views/users_controller/new.html.erb
```

What happened? Well - it turns out that the server wants to direct us to the page /users/new.html. That's a problem, because we haven't actually created it yet. On the bright side, we've discovered something awesome - LiteRail's build in error handling. Right here in the browser you can see the error that was raised, the stack trace, and a preview of the source code that caused the glitch. You can even customize the depth of the stack trace - give it a shot. Next, we'll create a proper HTML page, update our routes, and add some users.

Last modified: August 10, 2016: 9:14 PM
TODO: Check that the server can create and persist model instances.
