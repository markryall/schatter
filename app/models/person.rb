require 'uuid_generator'

class Person < ActiveRecord::Base
  extend UuidGenerator
  include UuidGenerator

  attr_accessible :email, :name, :uuid, :auth_token

  has_many :memberships
  has_many :conversations, through: :memberships
  has_many :messages

  def self.find_or_create_for_email email
    person = Person.find_by_email email
    return person if person
    Person.create email: email, uuid: new_uuid, auth_token: new_uuid
  end

  def create_conversation name
    join_conversation Conversation.create uuid: new_uuid, name: name
  end

  def join_conversation conversation
    Membership.create person: self, conversation: conversation
    conversation
  end

  def create_message params
    Message.create params.merge({person: self, uuid: new_uuid})
  end

  def to_hal urls
    {
      uuid: uuid,
      email: email,
      timestamp: created_at.to_i,
      _links: {
        self: { href: urls.person_url(id: uuid) }
      }
    }
  end
end
