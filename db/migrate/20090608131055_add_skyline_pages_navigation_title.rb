class AddSkylinePagesNavigationTitle < ActiveRecord::Migration
  def self.up
    add_column :skyline_pages, :navigation_title, :string
  end

  def self.down
    remove_column :skyline_pages, :navigation_title
  end
end
