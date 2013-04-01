class MessagesController < ApplicationController
  def index
    with_conversation params[:conversation_id] do |conversation|
      messages = conversation.messages
      message = Message.find_by_uuid params[:message_id] if params[:message_id]
      messages = messages.where('message_id > ?', message.id) if message
      render json: { messages: messages.map {|message| message.to_hal self } }
    end
  end

  def show
    with_message params[:id] do |conversation|
      render json: conversation.to_hal(self)
    end
  end

  def create
    with_conversation params[:conversation_id] do |conversation|
      parent = Message.find_by_uuid params[:parent_id] if params[:parent_id]
      message = current_person.create_message conversation: conversation,
        content: params[:content],
        message: parent
      render json: message.to_hal(self), status: 201
    end
  end

  def destroy
    message = Message.find_by_uuid params[:id]
    if message && message.person == current_person
      message.destroy
      render json: message.to_hal(self)
    else
      render json: {error: 'unknown message'}, status: 404
    end
  end
end
