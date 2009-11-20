class AddAssociatedTagId < ActiveRecord::Migration
  def self.up
    add_column :skyline_associated_tags, :id, :primary_key, :null => false
  end

  def self.down
    remove_column :skyline_associated_tags, :id
  end
end
