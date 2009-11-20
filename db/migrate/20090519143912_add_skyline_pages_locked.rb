class AddSkylinePagesLocked < ActiveRecord::Migration
  def self.up
  	add_column :skyline_pages, :locked, :boolean, :default => false, :null => false
  end

  def self.down
  	remove_column :skyline_pages, :locked
  end
end
