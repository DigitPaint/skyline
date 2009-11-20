class CreateSkylineWysiwygSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_wysiwyg_sections do |t|
      t.column :body, :mediumtext
      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_wysiwyg_sections
  end
end
