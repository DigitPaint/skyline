class CreateSkylineContentCollectionSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_content_collection_sections do |t|
      t.string :content_type, :null => false
      t.integer :number, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_content_sections
  end
end
