class MessagesController < ApplicationController
  def index
    with_conversation do |conversation|
      render json: { messages: conversation.messages.map(&:to_hal) }
    end
  end

  def create
    with_conversation do |conversation|
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