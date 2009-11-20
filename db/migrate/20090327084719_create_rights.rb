class CreateRights < ActiveRecord::Migration
  def self.up
    create_table :rights do |t|
      t.column :name, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :rights
  end
end
