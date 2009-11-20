class CreateSkylineActions < ActiveRecord::Migration
  def self.up
    create_table :skyline_actions do |t|
      t.column :type, :string
      t.column :class_name, :string
      t.column :record_id, :integer
      t.column :perform_at, :timestamp
    end
  end

  def self.down
    drop_table :skyline_actions
  end
end
