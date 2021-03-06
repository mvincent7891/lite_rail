require 'rack'
require_relative 'lib/controller_base.rb'
require_relative 'lib/router'
require_relative 'lib/static'
require_relative 'lib/show_exceptions'
require_relative 'lib/flash'

# require controllers here
require_relative 'app/controllers/application_controller.rb'


router = Router.new
router.draw do
  get Regexp.new("^/index$"), ApplicationController, :index
  # get Regexp.new("^/users/new$"), UsersController, :new
  # post Regexp.new("^/users$"), UsersController, :create
  # get Regexp.new("^/users$"), UsersController, :index
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use ShowExceptions
  use Static
  run app
end.to_app

Rack::Server.start(
 app: app,
 Port: 3000
)
