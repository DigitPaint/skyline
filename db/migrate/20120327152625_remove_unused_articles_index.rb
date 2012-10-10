class RemoveUnusedArticlesIndex < ActiveRecord::Migration
  def self.up
    begin
      remove_index :skyline_articles, :name => "sp_page_id_in_navigation"
    rescue 
      puts "Could not remove index: sp_page_id_in_navigation"
    end
  end

  def self.down
    add_index :skyline_pages, [:page_id, :in_navigation], :name => "sp_page_id_in_navigation"
  end
end
