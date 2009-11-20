class CreateSkylineLinkSectionLinks < ActiveRecord::Migration
  def self.up
    create_table :skyline_link_section_links do |t|
      t.integer :link_section_id, :null => false
      t.integer :linked_id
      t.string :custom_url
      t.string :title
      t.integer :position, :null => false
      t.timestamps
    end
    add_index :skyline_link_section_links, [:link_section_id, :position]
  end

  def self.down
    drop_table :skyline_link_section_links
  end
end
