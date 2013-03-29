class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :conversation_id
      t.integer :person_id
      t.integer :message_id
      t.text :content

      t.timestamps
    end
  end
end
