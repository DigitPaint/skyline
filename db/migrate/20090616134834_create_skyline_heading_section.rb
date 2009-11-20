class CreateSkylineHeadingSection < ActiveRecord::Migration
  def self.up
    create_table :skyline_heading_sections do |t|
      t.string :heading, :null => false
      t.timestamps
    end    
  end

  def self.down
    drop_table :skyline_heading_sections
  end
end
