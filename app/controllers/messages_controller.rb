class MessagesController < ApplicationController
  def index
    with_conversation params[:conversation_id] do |conversation|
      render json: { messages: messages_to_hal(conversation.messages) }
    end
  end

  def show
    with_message params[:id] do |conversation|
      render json: conversation_to_hal(conversation)
    end
  end

  def create
    with_conversation params[:conversation_id] do |conversation|
      message = current_person.create_message conversation, params[:content]
      render json: message.to_hal, status: 201
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
