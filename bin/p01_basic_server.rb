require 'rack'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  res['Content-Type'] = 'text/html'
  text = req.path
  res.write("Hello world! Path is #{text}")
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
