require 'uuidtools'

module UuidGenerator
  def new_uuid
    UUIDTools::UUID.random_create.to_s
  end
end
