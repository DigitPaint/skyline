class CreateSkylineLinkSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_link_sections do |t|
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_link_sections
  end
end
