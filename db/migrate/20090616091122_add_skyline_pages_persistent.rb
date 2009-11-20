class AddSkylinePagesPersistent < ActiveRecord::Migration
  def self.up
    add_column :skyline_pages, :persistent, :boolean, :null => false, :default => false
    execute "UPDATE skyline_pages SET persistent=1 WHERE page_id IS NULL"
  end

  def self.down
    remove_column :skyline_pages, :persistent
  end
end
