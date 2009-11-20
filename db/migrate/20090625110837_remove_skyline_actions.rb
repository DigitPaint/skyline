class RemoveSkylineActions < ActiveRecord::Migration
  def self.up
    drop_table :skyline_actions
  end

  def self.down
    create_table "skyline_actions", :force => true do |t|
      t.string   "type"
      t.string   "class_name"
      t.integer  "record_id"
      t.datetime "perform_at"
    end
  end
end
