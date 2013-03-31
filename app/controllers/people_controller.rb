class PeopleController < ApplicationController
  def create
    with_conversation params[:conversation_id] do |conversation|
      person = Person.find_or_create_for_email params[:email]
      person.join_conversation conversation unless conversation.people.include?(person)
      render json: person, status: 201
    end
  end
end
