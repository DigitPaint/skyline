class CreateSkylinePages < ActiveRecord::Migration
  def self.up
    create_table :skyline_pages do |t|
      t.references :page
      t.references :published_publication
      t.boolean :in_navigation, :null => false, :default => false
      t.integer :position, :null => false
      t.timestamps
    end
    add_index :skyline_pages, [:page_id, :position], :name => "sp_page_id_position"
    add_index :skyline_pages, [:page_id, :in_navigation], :name => "sp_page_id_in_navigation"
  end

  def self.down
    drop_table :skyline_pages
  end
end
