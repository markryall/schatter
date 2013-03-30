require 'uuid_generator'

class Person < ActiveRecord::Base
  extend UuidGenerator
  include UuidGenerator

  attr_accessible :email, :name, :auth_token

  has_many :memberships
  has_many :conversations, through: :memberships
  has_many :messages

  def self.find_or_create_for_email email
    person = Person.find_by_email email
    return person if person
    Person.create email: email, auth_token: uuid
  end

  def create_conversation
    join_conversation Conversation.create uuid: uuid
  end

  def join_conversation conversation
    Membership.create person: self, conversation: conversation
    conversation
  end

  def create_message conversation, content
    Message.create person: self, conversation: conversation, uuid: uuid, content: content
  end

  def to_hal
    {
      uuid: uuid,
      email: email,
      timestamp: created_at.to_i
    }
  end
end
