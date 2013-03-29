class RootController < ApplicationController
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
            self: { href: root_url },
            conversations: { href: conversation_index_url }
          }
        }
      end
    end
  end

  def logout
    session[:email] = nil
    redirect_to root_url
  end
end