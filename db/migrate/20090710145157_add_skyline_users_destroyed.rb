class AddSkylineUsersDestroyed < ActiveRecord::Migration
  def self.up
    add_column :skyline_users, :destroyed, :boolean, :default => false
  end

  def self.down
    remove_column :skyline_users, :destroyed
  end
end
