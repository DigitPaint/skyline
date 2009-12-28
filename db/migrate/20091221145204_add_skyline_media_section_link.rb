class AddSkylineMediaSectionLink < ActiveRecord::Migration
  def self.up
    rename_column :skyline_sections_media_sections, :linked_id, :media_id
    add_column :skyline_sections_media_sections, :link_id, :integer
  end

  def self.down
    rename_column :skyline_sections_media_sections, :media_id, :linked_id
    remove_column :skyline_sections_media_sections, :link_id
  end
end
