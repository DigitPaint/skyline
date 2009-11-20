class CreateSkylineSplitterSection < ActiveRecord::Migration
  def self.up
    create_table :skyline_splitter_sections do |t|
      t.timestamps
    end    
  end

  def self.down
    drop_table :skyline_splitter_sections
  end
end
