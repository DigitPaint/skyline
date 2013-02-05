class CreateSkylineSessions < ActiveRecord::Migration
  def up
    create_table :skyline_sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :skyline_sessions, :session_id
    add_index :skyline_sessions, :updated_at
  end

  def self.down
    drop_table :skyline_sessions
  end
end
