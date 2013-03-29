class ConversationsController < ApplicationController
  def index
    render json: {}
  end

  def create
    conversation = current_person.create_conversation
    render json: conversation.to_hal
  end
end