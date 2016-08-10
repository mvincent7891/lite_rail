require 'erb'
require 'byebug'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    # ['200', {'Content-Type' => 'text/html'}, ['hello world']]
    status_code = 100.to_s
    content_type = {'Content-Type' => 'text/html'}
    content = ['there is an error']

    [status_code, content_type, content]
  end

end
