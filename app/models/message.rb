class Message < ActiveRecord::Base
  attr_accessible :content

  belongs_to :conversation
  belongs_to :person
end
