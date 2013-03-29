class Membership < ActiveRecord::Base
  attr_accessible :conversation, :person

  belongs_to :conversation
  belongs_to :person
end
