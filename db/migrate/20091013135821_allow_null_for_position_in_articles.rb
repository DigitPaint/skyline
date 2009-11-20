class AllowNullForPositionInArticles < ActiveRecord::Migration
  def self.up
    change_column :skyline_articles, :position, :integer, :null => true
  end

  def self.down
    change_column :skyline_articles, :position, :integer, :null => true
  end
end
