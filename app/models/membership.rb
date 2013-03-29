class Membership < ActiveRecord::Base
  attr_accessible :conversation_id, :person_id
end
