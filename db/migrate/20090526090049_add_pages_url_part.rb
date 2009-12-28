class AddPagesUrlPart < ActiveRecord::Migration
  def self.up
    add_column :skyline_pages, :url_part, :string, :null => false, :default => ""
  end

  def self.down
    remove_column :skyline_pages, :url_part
  end
end
