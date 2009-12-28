class AddSkylinePagesPersistent < ActiveRecord::Migration
  def self.up
    add_column :skyline_pages, :persistent, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :skyline_pages, :persistent
  end
end
