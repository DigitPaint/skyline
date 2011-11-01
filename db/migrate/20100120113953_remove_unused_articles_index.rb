class RemoveUnusedArticlesIndex < ActiveRecord::Migration
  def self.up
    remove_index :skyline_articles, :name => "sp_page_id_in_navigation"
  end

  def self.down
    # No backward, because this index is useless.
  end
end
