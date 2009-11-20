class AddSkylinePageVersionCurrentEditor < ActiveRecord::Migration
  def self.up
    add_column :skyline_page_versions, :current_editor_id, :integer
    add_column :skyline_page_versions, :current_editor_timestamp, :timestamp
    add_column :skyline_page_versions, :current_editor_since, :timestamp    
  end

  def self.down
    remove_column :skyline_page_versions, :current_editor_since    
    remove_column :skyline_page_versions, :current_editor_timestamp
    remove_column :skyline_page_versions, :current_editor_id
  end
end
