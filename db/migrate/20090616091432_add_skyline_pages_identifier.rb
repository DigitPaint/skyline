class AddSkylinePagesIdentifier < ActiveRecord::Migration
  def self.up
    add_column :skyline_pages, :identifier, :string
  end

  def self.down
    remove_column :skyline_pages, :identifier
  end
end
