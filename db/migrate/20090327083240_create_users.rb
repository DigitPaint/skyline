class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :name, :string      
      t.column :email, :string
      t.column :password, :string
      t.column :preferences, :string
      
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
