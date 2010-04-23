class AddTags < ActiveRecord::Migration
  def self.up
    create_table :skyline_tags do |t|
      t.column :tag, :string
    end
  end

  def self.down
    drop_table :skyline_tags
  end
end
