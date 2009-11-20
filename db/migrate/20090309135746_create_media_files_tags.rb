class CreateMediaFilesTags < ActiveRecord::Migration
  def self.up
    create_table :media_files_tags, :id => false do |t|
      t.column :media_file_id, :integer
      t.column :tag_id, :integer
    end
  end

  def self.down
    drop_table :media_files_tags
  end
end
