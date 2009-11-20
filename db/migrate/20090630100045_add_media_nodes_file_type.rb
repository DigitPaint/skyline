class AddMediaNodesFileType < ActiveRecord::Migration
  def self.up
    add_column :skyline_media_nodes, :file_type, :string
    Skyline::MediaFile.set_missing_file_types
  end

  def self.down
    remove_column :skyline_media_nodes, :file_type
  end
end
