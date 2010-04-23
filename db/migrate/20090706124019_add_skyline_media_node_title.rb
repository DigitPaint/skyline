class AddSkylineMediaNodeTitle < ActiveRecord::Migration
  def self.up
    add_column :skyline_media_nodes, :title, :string
    remove_column :skyline_media_nodes, :hidden
  end

  def self.down
    add_column :skyline_media_nodes, :hidden, :boolean,       :default => false
    remove_column :skyline_media_nodes, :title
  end
end
