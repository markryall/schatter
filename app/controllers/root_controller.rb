class RootController < ApplicationController
  skip_filter :require_login

  def index
    if logged_in?
      redirect_url = session[:initial_url] || home_url
      session[:initial_url] = nil
      redirect_to redirect_url
    end
  end
end