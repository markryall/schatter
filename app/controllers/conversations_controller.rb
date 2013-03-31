class ConversationsController < ApplicationController
  def index
    render json: {conversations: current_person.conversations.map {|conversation| conversation.to_hal self } }
  end

  def show
    with_conversation params[:id] do |conversation|
      render json: conversation.to_hal(self)
    end
  end

  def create
    conversation = current_person.create_conversation params[:name]
    render json: conversation.to_hal(self), status: 201
  end
end
