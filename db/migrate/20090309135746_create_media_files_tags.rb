class CreateMediaFilesTags < ActiveRecord::Migration
  def self.up
    create_table :skyline_media_files_skyline_tags, :id => false do |t|
      t.column :media_file_id, :integer
      t.column :tag_id, :integer
    end
  end

  def self.down
    drop_table :skyline_media_files_skyline_tags
  end
end
