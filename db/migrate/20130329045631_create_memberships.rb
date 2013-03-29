class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.integer :conversation_id
      t.integer :person_id

      t.timestamps
    end
  end
end
