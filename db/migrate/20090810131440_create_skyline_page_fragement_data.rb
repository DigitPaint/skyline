class CreateSkylinePageFragementData < ActiveRecord::Migration
  def self.up
    create_table :skyline_page_fragment_data, :force => true do |t|
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_page_fragment_data
  end
end
