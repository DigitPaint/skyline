class CreateRefObjects < ActiveRecord::Migration
  def self.up
    create_table :ref_objects do |t|
      t.integer :id
      t.integer :referable_id
      t.string :referable_type
      t.integer :refering_id
      t.string :refering_type
      t.string :type
      t.text :options

      t.timestamps
    end
  end

  def self.down
    drop_table :ref_objects
  end
end
