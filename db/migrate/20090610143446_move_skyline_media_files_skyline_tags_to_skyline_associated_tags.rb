class MoveSkylineMediaFilesSkylineTagsToSkylineAssociatedTags < ActiveRecord::Migration
  def self.up
    rename_table :skyline_media_files_skyline_tags, :skyline_associated_tags
    rename_column :skyline_associated_tags, :media_file_id, :taggable_id
    add_column :skyline_associated_tags, :taggable_type, :string, :null => false, :default => ""
    execute "UPDATE skyline_associated_tags SET taggable_type='Skyline::MediaNode'"
  end

  def self.down
    remove_column :skyline_associated_tags, :taggable_type
    rename_column :skyline_associated_tags, :taggable_id, :media_file_id
    rename_table :skyline_associated_tags, :skyline_media_files_skyline_tags
  end
end
