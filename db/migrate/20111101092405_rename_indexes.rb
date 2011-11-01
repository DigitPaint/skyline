class RenameIndexes < ActiveRecord::Migration
  def self.up
    [
      ["skyline_articles", "index_skyline_pages_on_page_id_and_position", "sp_page_id_position"],
      ["skyline_articles", "index_skyline_pages_on_page_id_and_in_navigation", "sp_page_id_in_navigation"],
      ["skyline_article_versions", "index_skyline_page_versions_on_type_and_page_id_and_version", "spv_type_page_id_version"],
      ["skyline_article_versions", "index_skyline_page_versions_on_url_part", "spv_url_part"],
      ["skyline_sections", "index_skyline_sections_on_page_version_id_and_position", "ss_page_version_id_position"],
      ["skyline_tags", "index_skyline_tags_on_taggable_type_and_tag", "sk_taggable_type_tag"],
      ["skyline_link_section_links", "index_skyline_link_section_links_on_link_section_id_and_position", "slsl_link_section_id_position"],
      ["skyline_associated_tags", "index_skyline_associated_tags_on_taggable_type_and_taggable_id_and_tag_id", "sat_tt"],
    ].each do |tbl, old, nw|
      begin
        rename_index tbl, old, nw
      rescue 
        puts "Could not rename index '#{old}' on '#{tbl}'"
      end
    end
  end

  def self.down
    # Nothing to do here!
  end
end
