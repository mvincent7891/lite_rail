require 'rack'
require_relative '../lib/controller_base'


# a controller that simply redirects all
# request paths to "/cats", then rendering a
# response based on the content and type
# passed to render_content
class MyController < ControllerBase
  def go
    if @req.path == "/cats"
      # render_content("hello cats!", "text/html")
      json_pets = {
        cats: ['alley', 'fat'],
        dogs: ['top', 'under']
       }
      render_content(json_pets, "application/json")
    else
      redirect_to("/cats")
    end
  end
end

# creating a new Rack app that handles all responses
# by instantiating the MyController with the
# response and request objects
app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  MyController.new(req, res).go
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
