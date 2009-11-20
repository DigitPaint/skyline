class AddDescriptionToMediaNodes < ActiveRecord::Migration
  def self.up
    add_column :media_nodes, :description, :text
  end

  def self.down
    remove_column :media_nodes, :description
  end
end
