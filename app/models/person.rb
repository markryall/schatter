class Person < ActiveRecord::Base
  attr_accessible :email, :name

  def self.create_for_email email
    Person.create email: email
  end
end
