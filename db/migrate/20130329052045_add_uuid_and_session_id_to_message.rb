class AddUuidAndSessionIdToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :uuid, :string
    add_column :messages, :session_id, :string
  end
end
