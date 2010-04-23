class AddDescriptionToMediaNodes < ActiveRecord::Migration
  def self.up
    add_column :skyline_media_nodes, :description, :text
  end

  def self.down
    remove_column :skyline_media_nodes, :description
  end
end
