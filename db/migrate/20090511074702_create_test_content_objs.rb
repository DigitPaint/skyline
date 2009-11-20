class CreateTestContentObjs < ActiveRecord::Migration
  def self.up
    create_table :test_content_objs do |t|      
      t.integer :image_id
      t.string :header
      
      t.timestamps
    end
  end

  def self.down
    drop_table :test_content_objs
  end
end
