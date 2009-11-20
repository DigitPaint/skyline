class PrefixTablesForSkyline < ActiveRecord::Migration
  def self.up
    rename_table :grants, :skyline_grants
    rename_table :media_caches, :skyline_media_cache
    rename_table :media_files_tags, :skyline_media_files_skyline_tags
    rename_table :media_nodes, :skyline_media_nodes

    rename_table :ref_objects, :skyline_ref_objects
    rename_table :rights, :skyline_rights
    rename_table :rights_roles, :skyline_rights_skyline_roles
    rename_table :roles, :skyline_roles
    rename_table :tags, :skyline_tags
    rename_table :users, :skyline_users
    rename_table :test_sections, :skyline_test_sections
  end

  def self.down
    rename_table :skyline_test_sections, :test_sections
    rename_table :skyline_users, :users
    rename_table :skyline_tags, :tags
    rename_table :skyline_roles, :roles
    rename_table :skyline_rights_skyline_roles, :rights_roles
    rename_table :skyline_rights, :rights
    rename_table :skyline_ref_objects, :ref_objects
    rename_table :skyline_grants, :grants
    rename_table :skyline_media_cache, :media_caches
    rename_table :skyline_media_files_skyline_tags, :media_files_tags
    rename_table :skyline_media_nodes, :media_nodes
  end
end
