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
    message = "hello world"
    # will show message when error is raised in app
    ['200', {'Content-Type' => 'text/html'}, [message]]
  end

end
