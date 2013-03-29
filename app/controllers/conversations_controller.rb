class ConversationsController < ApplicationController
  def index
    render json: {conversations: current_person.conversations.map(&:to_hal)}
  end

  def show
    with_conversation params[:id] do |conversation|
      render json: conversation.to_hal
    end
  end

  def create
    conversation = current_person.create_conversation
    render json: conversation.to_hal, status: 201
  end
end