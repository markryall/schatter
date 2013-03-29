class ConversationsController < ApplicationController
  def index
    render json: {conversations: conversations_to_hal(current_person.conversations) }
  end

  def show
    with_conversation params[:id] do |conversation|
      render json: conversation_to_hal(conversation)
    end
  end

  def create
    conversation = current_person.create_conversation
    render json: conversation_to_hal(conversation), status: 201
  end
end