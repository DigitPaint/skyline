class CreateSkylineContentItemSection < ActiveRecord::Migration
  def self.up
    create_table :skyline_content_item_sections do |t|
      t.string :content_item_type, :null => false
      t.integer :content_item_id, :null => false
      t.timestamps
    end    
  end

  def self.down
    drop_table :skyline_content_item_sections
  end
end
