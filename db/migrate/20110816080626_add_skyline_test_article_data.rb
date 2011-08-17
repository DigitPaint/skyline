class AddSkylineTestArticleData < ActiveRecord::Migration
  def self.up
    create_table :skyline_test_article_data, :force => true do |t|
      t.text :intro
      t.integer :link_id
      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_test_article_data
  end
end
