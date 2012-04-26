class AddTimestampsToSkylineMediaNodes < ActiveRecord::Migration
  def self.up
    add_column :skyline_media_nodes, :updated_at, :timestamp
    
    execute "UPDATE skyline_media_nodes SET updated_at = '#{Time.now.utc.to_formatted_s(:db)}'"
  end
  
  def self.down
    remove_column :skyline_media_nodes, :updated_at
  end
end