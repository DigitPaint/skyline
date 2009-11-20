class RenameTestContentObjs < ActiveRecord::Migration
  def self.up
  	rename_table :test_content_objs, :test_content_objects
  end

  def self.down
  	rename_table :test_content_objects, :test_content_objs
  end
end
