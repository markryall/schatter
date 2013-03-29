class MessagesController < ApplicationController
  def index
    render json: {}
  end

  def create
    conversation = Conversation.find_by_uuid params[:conversation_id]
    if conversation
      message = current_person.create_message conversation, params[:content]
      render json: message.to_hal, status: 201
    else
      render json: {error: 'unknown conversation'}, status: 404
    end
  end

  def destroy
    message = Message.find_by_uuid params[:message_id]
    if message
      message.destroy
      render json: message.to_hal
    else
      render json: {error: 'unknown message'}, status: 404
    end
  end
end