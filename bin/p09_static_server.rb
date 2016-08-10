require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/router'
require_relative '../lib/static'
require_relative '../lib/show_exceptions'


class MyController < ControllerBase
  protect_from_forgery

  def go
    render_content("Hello from the controller", "text/html")
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/$"), MyController, :go
  get Regexp.new("/public/.*"), MyController, :go
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
