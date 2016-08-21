# LiteRail README

## Overview:
A lite version of Rails with a sprinkling of ActiveRecord (also lite), built from the ground up (mostly). This README assumes a certain (>= intermediate) level of familiarity with the popular Ruby on Rails web development framework.

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
ruby 'app/models/db_utility.rb'
```
That will set up a database with one table, `users`. Check it out - using SQLite3, open the database from terminal with:

```
sqlite3 app/default.db
```
and check out the tables with:

```
.tables
```

To change the default database `schema` and `seed data`, edit your 'app/default.sql'. Every time you run the `db_utility`, the database will be reset with the seed data in that file. To establish a connection to the database within a ruby file, simply:

```
require 'app/model/db_connection.rb'
```
Let's add some new tables to the database. Run the following command from terminal, within the app's home directory:

```
ruby -r "./generate.rb" -e "model 'model_name'"
```
For instance, if you wish to create a new `comment` model with an associated `comments` table in the database, then your model_name would be `comment`. Now, let's say we want to create a table with a column or two in it. Simply tack on each addition column (along with its type and constraints) in an array as the second parameter to `#model`:

```
ruby -r "./generate.rb" -e "model('comment',['user_id INTEGER NOT NULL'])"
```
The above will create a new model file, `comment.rb` as well as a table called `comments` with both primary `id` and `user_id` columns, where the `user_id` is an integer that must be set before saving.

### Creating controllers
There should already be a users model within the models folder, but it looks like we're missing the associated controller. Let's fix that. Pop back over to terminal and execute the following:

```
ruby -r "./generate.rb" -e "controller('users')"
```
That's it! The newly generated users controller lives in `app/controllers/` folder along with the application controller, from which all controllers inherit. Now generate controllers for the rest of your models. Notice that when a controller is created, it only has access to the associated model.

```
require_relative 'app/controllers/application_controller'
require_relative 'app/models/user.rb'
...
```
If you need to access other models, just use associations (NB: `associatable` and `searchable` modules not yet connected to model base).

### Controller-Model Interface

Now let's see how the controller and model interact with each other. We're going to create a new user from within our controller.
* Open up your new controller model and override the `#initialize` method by writing a blank method (we'll need a server in the future before when we can initialize properly).
* OK - now write a `#new` method.
* This method should instantiate a new user with a name and age, then save the user.

Your users controller should now look like this

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
Great. Now how do we actually call this method? In some ideal future, our router would call the `#new` method when given some `HTTP request`. But for now, hop on over to the terminal and open pry. Let's load the users controller file, instantiate a new controller, and call the `#new` method.

```
pry(main)> load 'app/controllers/users_controller.rb'
=> true
pry(main)> uc = UsersController.new
=> #<UsersController:0x007fa57aa48e78>
pry(main)> uc.new
=> 3

```

Hmm... did that work? Well, we have our lite version of object relational mapping (aka ActiveRecord) - let's use it! Call User.all and see if you've successfully created a new user. What next? Well - let's see if we can do the same thing from the interwebs.

### Built-in Server

Go ahead and delete the `#initialize` method you wrote into the users controller. Now, let's add some routes to our project. Open up your `server.rb` file and peruse the contents.
* First and foremost, we require the files LiteRail needs to achieve some basic functionality. I'll leave the details for your reading pleasure.
* Next, you'll notice that application_controller.rb has been required. This allows us to build routes that call on the controller's methods. If you want to build routes to other controllers, require the source files here.
* Check out the router - we use `regular expressions` to define the path to a specific controller and method
* To test our LiteRail app, we use Rack's built in functions (`::Builder.new` and `::Server.start`).

Great! Now, let's get the thing working. Open up terminal and run the following:

```
~.../LiteRail$ ruby server.rb
[2016-08-10 20:40:16] INFO  WEBrick 1.3.1
[2016-08-10 20:40:16] INFO  ruby 2.3.1 (2016-04-26) [x86_64-darwin15]
[2016-08-10 20:40:16] INFO  WEBrick::HTTPServer#start: pid=71490 port=3000
```

WEBrick is a freeby with Rack - a simple server for development. With that command, we're rolling. Open up your favorite web browser and navigate to `localhost:3000/index` - you should be greeted with LiteRail's default index page. What about the users controller we added? Add the controller to the required files in the server file, like so:

```RUBY
# require controllers here
require_relative 'app/controllers/application_controller.rb'
require_relative 'app/controllers/users_controller.rb'
...
```
Now what was it we wanted to do? Create a new user, right? Let's navigate to `localhost:3000/users/new`.

Hm - that didn't work. We haven't actually created the route `/users/new` yet, so LiteRail let's us know what's missing. On the bright side, we've discovered something awesome - LiteRail's built in error handling!

### Error Handling

By navigating to `/users/new`, the browser made a `GET` request to the users controller. But since that route is not yet defined, LiteRail raised an exception. Right here in the browser you can see the error message, the stack trace, and a preview of the source code that caused the glitch. You can even customize the depth of the stack trace - give it a shot. Looking at the source code, lines 70 - 71, we can see exactly what caused the error - the route was `nil` (not found). Let's fix that.

To create the missing route, just uncomment the second statement in the router.draw block (`server.rb`). How convenient :)

```RUBY
router = Router.new
router.draw do
  get Regexp.new("^/index$"), ApplicationController, :index
  get Regexp.new("^/users/new$"), UsersController, :new
end
```

Now, let's give it a whirl. Head to `localhost:3000/users/new`.

```
No such file or directory @ rb_sysopen - app/views/users_controller/new.html.erb
```

What happened? Well - it turns out that the router wants to direct us to the `view`, `/users/new.html`. That's a problem, because we haven't actually created it yet. But, again, we get some helpful hints from LiteRail's error handler. If we were to delete the `#new` method from our users controller, we'd see a similarly helpful message.

### Views

Enough errors - let's get something working. We need to create a new `HTML` file which the `#new` method can render upon request. In its infinite wisdom, and unbeknownst to you, LiteRail already created the `app/views/users_controller/` folder when you generated the users controller. This views folder is where your users `HTML` will live. Create a new file, `views/users_controller/new.html.erb`, and paste the following:

```HTML
<form class="" action="users" method="post">
  <label>Name:
    <input type="text" name="user[name]" value="">
  </label>

  <label>Age:
    <input type="text" name="user[age]" value="">
  </label>

  <input type="submit" value="Create User">
</form>
```

Save your work, navigate back to `localhost:3000/users/new`, and you should see the newly created form. Excellent! Next, we'll create a proper `HTML` page, update our routes, and add some users.

Last modified: August 12
TODO: Re-write #create, #index and #new in users controller, update routes, create users.

### The Model-View-Controller Interface
Instructions coming soon...

### Protection from Forgery
Instructions coming soon...

#### Searchable
You can query the database with chainable `#where` statements. For instance, if you wish to find all users with the name 'Matt', simply use the following:

```RUBY
User.where(name: 'Matt')
```

This will return a relation object with an `@query` instance variable that defines the SQL query. What if we want to use multiple parameters to find a specific user? There are two ways to accomplish this:

```RUBY

User.where(name: 'Matt', id: 3).to_a

# ...or...

User.where(name: 'Matt').where(id: 3).to_a

```

The above demonstrates that `#where` statements are chainable within LiteRail. The `#to_a` method will return an actual `user` object (or objects) instead of the relation object.

#### Associatable
Just like in Rails, LiteRail makes it easy to associate models with each other via associations. To start, create a new `post` model from terminal with user_id and body columns:

```
ruby -r "./generate.rb" -e "model('post',
['user_id INTEGER NOT NULL', 'body TEXT'])"
```

You can prove that this worked by opening the database and checking the table, or we can just seed the database, run the utility, and check that our seeds exist in pry. To seed the database, copy and paste the following in your `default.sql`:

```RUBY
INSERT INTO
  posts (id, user_id, body)
VALUES
  (1, 1, "My first post!");
```

NB: We could have also created a post by loading `post.rb` in pry and creating it manually.

Above your entry, you should see the posts table that was automatically added when you created the model from terminal. Note that the following example will not work if you have deleted your user with an ID of 1. In that case, just change the `user_id` in the above code to one that exists.

Next, we need to rerun the database utility to add the post. Remember how to do that?

```
ruby 'app/models/db_utility.rb'
```

Now, in terminal, open up pry. Let's run the following to see our new post:

```
pry(main)> load 'app/models/post.rb'
=> true
pry(main)> Post.all
=> [#<Post:0x007fc5f6358a68 @attributes={:id=>1, :user_id=>1, :body=>"My first post!"}>]
```

To associate the models with each other, head to the  `post.rb` and `user.rb` files and require each of them in the other. In each file, just write the desired association:

```RUBY
# in /post.rb...
...
belongs_to :user
...

# in /user.rb...
...
has_many :posts
...
```
We can check if it worked in pry. Load `user.rb` (You may need to exit and reopen pry first). Did it work?

```
pry(main)> load 'app/models/user.rb'
=> true
[14] pry(main)> User.all.to_a[0].posts
=> #<Relation:0x007fc5f360fef8
 @klass=Post,
 @params={:user_id=>1},
 @query="      SELECT\n        *\n      FROM\n        posts\n      WHERE\n        user_id = ?\n",
 @table="posts",
 @values=[1]>
pry(main)> User.all.to_a[0].posts.first
=> #<Post:0x007fc5f36a6740 @attributes={:id=>1, :user_id=>1, :body=>"My first post!"}>
```

The third command uses `#first` to make the result look a little prettier and bring it out of relation syntax. Now make sure you can check a post's associated user.



### Flash and Session
Instructions coming soon...

### Static Assets
Instructions coming soon...

### The Router, Explained
Instructions coming soon...

### More on ControllerBase
Instructions coming soon...
