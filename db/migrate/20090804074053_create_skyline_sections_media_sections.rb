class CreateSkylineSectionsMediaSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_sections_media_sections do |t|
      t.integer :linked_id
      t.string :custom_url
      t.string :alignment
      t.integer :width
      t.integer :height
      t.text :caption
    end
  end

  def self.down
    drop_table :skyline_sections_media_sections
  end
end
