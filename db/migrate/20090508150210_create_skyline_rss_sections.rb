class CreateSkylineRssSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_rss_sections do |t|
      t.string :url
      t.integer :show_count
      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_rss_sections
  end
end
