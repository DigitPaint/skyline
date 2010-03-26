class AddAssociatedTagsIndex < ActiveRecord::Migration
  def self.up
    add_index :skyline_associated_tags, [:taggable_type, :taggable_id, :tag_id], :name => "sat_ttt"
  end

  def self.down
    remove_index :skyline_associated_tags, :name => "sat_ttt"
  end
end
