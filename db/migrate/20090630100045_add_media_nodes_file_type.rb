class Skyline::MediaFile < Skyline::MediaNode
  def set_file_type!
    file_type = determine_file_type
    self.update_attribute(:file_type, file_type) unless file_type.blank?
  end
end

class AddMediaNodesFileType < ActiveRecord::Migration
  
  def self.up
    add_column :skyline_media_nodes, :file_type, :string
    Skyline::MediaFile.all(:conditions => "file_type = '' OR file_type IS NULL").each do |media_file|
      media_file.set_file_type!
    end
    
  end

  def self.down
    remove_column :skyline_media_nodes, :file_type
  end
end
