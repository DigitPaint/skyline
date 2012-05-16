class CreateSkylineMediaSizes < ActiveRecord::Migration
  def up
    create_table :skyline_media_sizes do |t|
      t.integer :media_file_id
      t.integer :width
      t.integer :height
      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_media_sizes
  end
end
