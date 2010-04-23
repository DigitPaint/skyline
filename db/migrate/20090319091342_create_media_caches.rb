class CreateMediaCaches < ActiveRecord::Migration #:nodoc:
  def self.up
    create_table :skyline_media_cache do |t|
      t.column :url, :string
      t.column :object_type, :string
      t.column :object_id, :integer
    end
  end

  def self.down
    drop_table :skyline_media_cache
  end
end
