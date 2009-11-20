class CreateSkylineVersions < ActiveRecord::Migration
  def self.up
    create_table :skyline_versions do |t|
      t.column :versionable_id, :integer
      t.column :versionable_type, :string
      t.column :version, :integer
      t.column :author, :string
    end
  end

  def self.down
    drop_table :skyline_versions
  end
end
