class PeopleController < ApplicationController
  def index
    with_conversation params[:conversation_id] do |conversation|
      render json: { people: conversation.people.map {|person| person.to_hal self } }
    end
  end

  def create
    with_conversation params[:conversation_id] do |conversation|
      person = Person.find_or_create_for_email params[:email]
      person.join_conversation conversation unless conversation.people.include?(person)
      render json: person.to_hal(self), status: 201
    end
  end
end
