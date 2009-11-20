class CreateGrants < ActiveRecord::Migration
  def self.up
    create_table :grants, :id => false do |t|
      t.column :user_id, :integer
      t.column :role_id, :integer
    end
  end

  def self.down
    drop_table :grants
  end
end
