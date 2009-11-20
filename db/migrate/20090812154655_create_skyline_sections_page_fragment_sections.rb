class CreateSkylineSectionsPageFragmentSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_sections_page_fragment_sections do |t|
      t.integer :page_fragment_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_sections_page_fragment_sections
  end
end
