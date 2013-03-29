require 'uuid_generator'

class Person < ActiveRecord::Base
  extend UuidGenerator

  attr_accessible :email, :name, :auth_token

  def self.create_for_email email
    Person.create email: email,
      auth_token: uuid
  end
end
