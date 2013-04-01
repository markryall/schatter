require 'uuid_generator'

class Conversation < ActiveRecord::Base
  extend UuidGenerator

  attr_accessible :uuid, :name

  has_many :memberships
  has_many :people, through: :memberships
  has_many :messages

  def to_hal urls
    {
      uuid: uuid,
      name: name,
      timestamp: created_at.to_i,
      _links: {
        self: { href: urls.conversation_url(id: uuid) },
        messages: { href: urls.conversation_messages_url(conversation_id: uuid) },
        people: { href: urls.conversation_people_url(conversation_id: uuid) }
      }
    }
  end
end
