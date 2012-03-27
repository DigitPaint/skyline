class RemoveUnusedArticlesIndex < ActiveRecord::Migration
  def up
    remove_index :skyline_articles, :name => "sp_page_id_in_navigation"
  end

  def down
    add_index :skyline_pages, [:page_id, :in_navigation], :name => "sp_page_id_in_navigation"
  end
end
