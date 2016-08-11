require 'rack'
require_relative '../../lib/controller_base.rb'
require_relative '../../lib/router'
require_relative '../../lib/static'
require_relative '../../lib/show_exceptions'
require_relative '../../lib/flash'

class ApplicationController < ControllerBase
  # Uncomment if form_authenticity_token will be used in forms
  # protect_from_forgery

  def index
    render :index
  end
end
