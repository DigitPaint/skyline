class CreateSkylineSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_sections do |t|
      t.references :page_version
      t.references :sectionable, :polymorphic => true
      t.integer :position, :null => false, :default => 1
      t.string :template
      t.timestamps
    end
    
    add_index :skyline_sections, [:page_version_id, :position]
  end

  def self.down
    drop_table :skyline_sections
  end
end
