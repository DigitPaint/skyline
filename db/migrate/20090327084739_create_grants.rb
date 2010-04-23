class CreateGrants < ActiveRecord::Migration
  def self.up
    create_table :skyline_grants, :id => false do |t|
      t.column :user_id, :integer
      t.column :role_id, :integer
    end
  end

  def self.down
    drop_table :skyline_grants
  end
end
