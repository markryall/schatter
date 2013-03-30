require 'uuid_generator'

class Conversation < ActiveRecord::Base
  extend UuidGenerator

  attr_accessible :uuid

  has_many :memberships
  has_many :people, through: :memberships
  has_many :messages

  def to_hal
    {
      uuid: uuid,
      timestamp: created_at.to_i
    }
  end
end
