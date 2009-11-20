class AddSkylineGrantsPrimaryKey < ActiveRecord::Migration
  def self.up
    add_column :skyline_grants, :id, :primary_key
  end

  def self.down
    remove_column :skyline_grants, :id
  end
end
