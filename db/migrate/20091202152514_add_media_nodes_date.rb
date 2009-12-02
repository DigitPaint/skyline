class AddMediaNodesDate < ActiveRecord::Migration
  def self.up
    add_column :skyline_media_nodes, :date, :date
  end

  def self.down
    remove_column :skyline_media_nodes, :date
  end
end
