require 'uuid_generator'

class Person < ActiveRecord::Base
  extend UuidGenerator
  include UuidGenerator

  attr_accessible :email, :name, :auth_token

  has_many :memberships
  has_many :conversations, through: :memberships
  has_many :messages

  def self.create_for_email email
    Person.create email: email,
      auth_token: uuid
  end

  def create_conversation
    conversation = Conversation.create uuid: uuid
    Membership.create person: self, conversation: conversation
    conversation
  end

  def create_message conversation, content
    Message.create person: self, conversation: conversation, uuid: uuid, content: content
  end
end
