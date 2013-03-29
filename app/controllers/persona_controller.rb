require 'persona'

class PersonaController < ApplicationController
  include Persona

  skip_filter :require_login

  def verify
    response = {}
    verify_persona { |email, response| session[:email] = email }
    render json: response
  end
end
