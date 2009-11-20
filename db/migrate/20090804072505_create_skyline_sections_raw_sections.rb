class CreateSkylineSectionsRawSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_sections_raw_sections do |t|
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_sections_raw_sections
  end
end
