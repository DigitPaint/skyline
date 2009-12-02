class RenameUsersDestroyedToIsDestroyed < ActiveRecord::Migration
  def self.up
    rename_column :skyline_users, :destroyed, :is_destroyed
  end

  def self.down
    rename_column :skyline_users, :is_destroyed, :destroyed
  end
end
