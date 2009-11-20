class RemovePageUrlPartConstraint < ActiveRecord::Migration
  def self.up
    change_column :skyline_articles, :url_part, :string, :null => true
    change_column :skyline_articles, :position, :integer, :default => 1
  end

  def self.down
    change_column :skyline_articles, :url_part, :string, :null => false
    change_column :skyline_articles, :position, :integer, :default => nil    
  end
end
