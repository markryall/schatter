class MessagesController < ApplicationController
  def index
    render json: {}
  end

  def create
    conversation = Conversation.find_by_uuid params[:conversation_id]
    message = current_person.create_message conversation, params[:content]
    render json: message.to_hal
  end
end