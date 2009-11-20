class AddSystemUsersFlag < ActiveRecord::Migration
  def self.up
    add_column :skyline_users, :system, :boolean, :default => false
  end

  def self.down
    remove_column :skyline_users, :system
  end
end
