class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :person_id
      t.string :uuid

      t.timestamps
    end
  end
end
