class MigratePagesToArticles < ActiveRecord::Migration
  def self.up
    rename_table :skyline_pages, :skyline_articles
    add_column :skyline_articles, :type, :string
    rename_column :skyline_articles, :page_id, :parent_id
    
    execute "UPDATE skyline_articles SET type = 'Skyline::Page'"
    
    rename_table :skyline_page_versions, :skyline_article_versions
    rename_column :skyline_article_versions, :page_id, :article_id
    rename_column :skyline_sections, :page_version_id, :article_version_id
  end

  def self.down
    rename_column :skyline_sections, :article_version_id, :page_version_id
    rename_column :skyline_article_versions, :article_id, :page_id
    rename_table :skyline_article_versions, :skyline_page_versions
        
    rename_column :skyline_articles, :parent_id, :page_id
    remove_column :skyline_articles, :type
    rename_table :skyline_articles, :skyline_pages
  end
end
