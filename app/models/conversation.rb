class Conversation < ActiveRecord::Base
  attr_accessible :uuid

  has_many :memberships
  has_many :conversations, through: :memberships
end
