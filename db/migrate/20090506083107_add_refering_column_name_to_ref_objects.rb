class AddReferingColumnNameToRefObjects < ActiveRecord::Migration
  def self.up
    add_column :ref_objects, :refering_column_name, :string
  end

  def self.down
    remove_column :ref_objects, :refering_column_name
  end
end
