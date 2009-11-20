class CreateSkylinePageVersions < ActiveRecord::Migration
  def self.up
    create_table :skyline_page_versions do |t|
      t.string :type, :null => false
      t.references :page, :null => false
      t.references :variant
      t.integer :version, :null => false, :default => 1
      t.string :url_part
      t.string :name, :null => false
      t.references :creator
      t.references :last_updated_by
      t.string :template
      t.string :title
      t.string :navigation_title
      t.string :title_tag
      t.string :meta_description_tag
      t.timestamps
    end
    
    add_index :skyline_page_versions, [:type, :page_id, :version]
    add_index :skyline_page_versions, :url_part
  end

  def self.down
    drop_table :skyline_page_versions
  end
end
