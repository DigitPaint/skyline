class AddMediaNodes < ActiveRecord::Migration
  def self.up
    create_table :skyline_media_nodes do |t|
      t.column :parent_id, :integer      
      t.column :type, :string      
      t.column :name, :string
      t.column :content_type, :string
      t.column :size, :integer
      t.column :path, :string
      t.column :hidden, :boolean, :default => false
    end
  end

  def self.down
    drop_table :skyline_media_nodes    
  end
end
