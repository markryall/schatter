require 'uuid_generator'

class Conversation < ActiveRecord::Base
  extend UuidGenerator

  attr_accessible :uuid

  has_many :memberships
  has_many :conversations, through: :memberships
  has_many :messages
end
