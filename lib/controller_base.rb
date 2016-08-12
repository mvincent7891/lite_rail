require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require_relative './flash'

class ControllerBase

  def self.protect_from_forgery
    @auth_token = SecureRandom.urlsafe_base64
  end

  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req, @res = req, res
    @params = params.merge(req.params)
  end

  def form_authenticity_token
    self.class.instance_eval {@auth_token}
  end

  def check_authenticity_token
    token = self.class.instance_eval {@auth_token}
    token == @req['authenticity_token'] || !token
  end


  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Cannot render twice" if @already_built_response
    @res['Location'] = url
    @res.status = 302
    session.store_session(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Cannot render twice" if @already_built_response
    @res.write(content)
    @res['Content-Type'] = content_type
    session.store_session(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    # create template path from self.class and template_name
    snake_class = self.class.to_s.split(/(?=[A-Z])/).map(&:downcase).join('_')
    template_path = "app/views/#{snake_class}/#{template_name.to_s}.html.erb"
    # translate conetnts of view at template_path into into html object;
    # use binding to ensure that we have access to controller's instance
    # variables
    evaluated_erb_template = ERB.new(File.read(template_path)).result(binding)
    render_content(evaluated_erb_template, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # method exposing a `Flash` object
  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    # ADD_ACTION_HERE
    if :create == name
      raise "Invalid authenticity token." unless check_authenticity_token
    end
    begin
      self.send(name)
    rescue
      raise "Not so fast, my friend... Undefined method <i>\##{name}</i> for #{self.class}."
    end
    render(name) unless already_built_response?
  end
end
