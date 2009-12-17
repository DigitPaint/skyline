class AddSkylineTagsTaggableType < ActiveRecord::Migration
  def self.up
    add_column :skyline_tags, :taggable_type, :string, :null => false, :default => ""
    add_index :skyline_tags, [:taggable_type, :tag]
    execute("UPDATE skyline_tags SET taggable_type='Skyline::MediaFile'")
  end

  def self.down
    remove_column :skyline_tags, :taggable_type
  end
end
