class CreateSkylineIframeSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_iframe_sections do |t|
      t.string :url
      t.integer :width
      t.integer :height
      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_iframe_sections
  end
end
