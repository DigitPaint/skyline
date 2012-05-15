class AddLockedToUsers < ActiveRecord::Migration
  def change
    add_column :skyline_users, :is_locked, :boolean, :default => false
  end
end
