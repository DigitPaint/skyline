class RenamePageTitleTag < ActiveRecord::Migration
  def self.up
    rename_column :skyline_page_versions, :title_tag, :custom_title_tag
  end

  def self.down
    rename_column :skyline_page_versions, :custom_title_tag, :title_tag
  end
end
