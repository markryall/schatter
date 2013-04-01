class Message < ActiveRecord::Base
  attr_accessible :person, :conversation, :uuid, :content

  belongs_to :conversation
  belongs_to :person
  belongs_to :message

  def to_hal urls
    {
      uuid: uuid,
      content: content,
      timestamp: created_at.to_i,
      person_id: person.uuid,
      _links: {
        self: { href: urls.message_url(id: uuid) }
      }
    }
  end
end