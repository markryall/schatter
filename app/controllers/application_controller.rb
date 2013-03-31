class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :require_login
  helper_method :current_person

  def require_login
    unless logged_in?
      respond_to do |format|
        format.html do
          session[:initial_url] = request.url
          redirect_to root_url
        end
        format.json do
          render json: {error: 'unauthorized'}, status: 401
        end
      end
    end
  end

  def logged_in?
    !!current_person
  end

  def current_person
    return @current_person if @current_person

    if params[:auth_token]
      @current_person = Person.find_by_auth_token params[:auth_token]
      if @current_person
        session[:email] = @current_person.email
        return @current_person
      end
    end

    return nil unless session[:email]

    @current_person = Person.find_by_email session[:email]
    @current_person = Person.create_for_email session[:email] unless @current_person
    @current_person
  end

  def with_message id
    message = Message.find_by_uuid id
    if message
      yield message
    else
      render json: {error: 'unknown message'}, status: 404
    end
  end

  def with_conversation id
    conversation = Conversation.find_by_uuid id
    if conversation && conversation.people.include?(current_person)
      yield conversation
    else
      render json: {error: 'unknown conversation'}, status: 404
    end
  end
end