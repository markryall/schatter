require 'uuid_generator'

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
      person: person.to_hal(urls),
      _links: {
        self: { href: urls.message_url(id: uuid, auth_token: 'AUTH_TOKEN') }
      }
    }
  end
end
