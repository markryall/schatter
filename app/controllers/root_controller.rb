require 'persona'
require 'google_oauth'

class RootController < ApplicationController
  include Persona
  include GoogleOauth

  skip_filter :require_login

  def index
    respond_to do |format|
      format.html do
        if logged_in?
          redirect_url = session[:initial_url] || home_url
          session[:initial_url] = nil
          redirect_to redirect_url
        end
      end
      format.json do
        render json: {
          _links: {
            self: { href: root_url(session_id: session_id) },
            conversations: { href: conversations_url(session_id: session_id) }
          }
        }
      end
    end
    @google_login = google_oauth_url
  end

  def persona_callback
    response = {}
    verify_persona { |email, response| session[:email] = email }
    render json: response
  end

  def google_oauth_callback
    verify_google_oauth { |email| session[:email] = email }
    redirect_to '/'
  end

  def logout
    session[:email] = nil
    redirect_to root_url
  end
end
