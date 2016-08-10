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
      render_exception(e, env)
    end
  end

  private

  def render_exception(e, env = nil)

    template_path = "lib/templates/rescue.html.erb"
    # stack_regex = Regexp.new("stack_depth=(\d+)")
    @path = env["PATH"]
    if env && env["QUERY_STRING"].match(Regexp.new("stack_depth"))
      @stack_depth = env["QUERY_STRING"].match(Regexp.new("\\d+"))[0].to_i
    else
      @stack_depth = 3
    end
    @error_message = e.message
    @backtrace = e.backtrace
    file_regex = Regexp.new("(.+):(\\d+)")
    match_data = e.backtrace[0].match(file_regex)
    @file_name = match_data[1]
    @line = match_data[2].to_i
    start_line = @line - 4
    end_line = @line + 2
    @source = []
    File.readlines(@file_name)[start_line..end_line].each_with_index do |line, index|
      @source << "Line #{index + @line - 3}: #{line}"
    end

    evaluated_erb_template = ERB.new(File.read(template_path)).result(binding)
    ['200', {'Content-Type' => 'text/html'}, [evaluated_erb_template]]
  end

end
