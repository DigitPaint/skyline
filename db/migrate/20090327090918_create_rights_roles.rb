class CreateRightsRoles < ActiveRecord::Migration
  def self.up
    create_table :skyline_rights_skyline_roles, :id => false do |t|
      t.column :right_id, :integer
      t.column :role_id, :integer
    end
  end

  def self.down
    drop_table :skyline_rights_skyline_roles
  end
end
