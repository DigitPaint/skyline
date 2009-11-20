class RemoveArticlesCachedFields < ActiveRecord::Migration
  def self.up
    remove_column :skyline_articles, :navigation_title
  end

  def self.down
    add_column :skyline_articles, :navigation_title, :string
  end
end
