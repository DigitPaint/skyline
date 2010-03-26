class CreateSkylineUserPreferences < ActiveRecord::Migration
  def self.up
    create_table :skyline_user_preferences do |t|
      t.integer :user_id
      t.string :key
      t.string :encoded_value
      t.timestamps
    end
  end

  def self.down
    drop_table :user_preferences
  end
end
