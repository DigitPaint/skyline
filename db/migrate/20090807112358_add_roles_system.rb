class AddRolesSystem < ActiveRecord::Migration
  def self.up
    add_column :skyline_roles, :system, :boolean, :null => false, :default => 0
  end

  def self.down
    remove_column :skyline_roles, :system
  end
end
