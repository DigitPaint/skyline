class CreateTestSections < ActiveRecord::Migration
  def self.up
    create_table :skyline_test_sections do |t|
      t.text :body_a
      t.text :body_b

      t.timestamps
    end
  end

  def self.down
    drop_table :skyline_test_sections
  end
end
