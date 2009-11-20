class AddPagesUrlPart < ActiveRecord::Migration
  def self.up
    add_column :skyline_pages, :url_part, :string, :null => false
    execute "UPDATE skyline_pages SET url_part = CONCAT('page-', position)"
    execute "UPDATE skyline_pages SET url_part = NULL where page_id is NULL"
  end

  def self.down
    remove_column :skyline_pages, :url_part
  end
end
