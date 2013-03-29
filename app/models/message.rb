require 'uuid_generator'

class Message < ActiveRecord::Base
  attr_accessible :person, :conversation, :uuid, :content

  belongs_to :conversation
  belongs_to :person
  belongs_to :message

  def to_hal
    {
      uuid: uuid,
      timestamp: created_at.to_i
    }
  end
end
