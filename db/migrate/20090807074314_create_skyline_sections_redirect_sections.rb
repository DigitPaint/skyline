class CreateSkylineSectionsRedirectSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_sections_redirect_sections do |t|
      t.integer :linked_id
      t.string :custom_url
      t.integer :delay, :null => false, :default => 0
    end    
  end

  def self.down
    drop_table :skyline_sections_redirect_sections
  end
end
