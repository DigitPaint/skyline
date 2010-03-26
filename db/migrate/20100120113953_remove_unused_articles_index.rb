class RemoveUnusedArticlesIndex < ActiveRecord::Migration
  def self.up
    remove_index :skyline_articles, :name => "index_skyline_pages_on_page_id_and_in_navigation"
  end

  def self.down
    # No backward, because this index is useless.
  end
end
