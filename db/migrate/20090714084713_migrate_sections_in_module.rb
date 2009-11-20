class MigrateSectionsInModule < ActiveRecord::Migration
  def self.up
    rename_table :skyline_content_collection_sections, :skyline_sections_content_collection_sections
    rename_table :skyline_content_item_sections, :skyline_sections_content_item_sections
    rename_table :skyline_heading_sections, :skyline_sections_heading_sections
    rename_table :skyline_iframe_sections, :skyline_sections_iframe_sections
    rename_table :skyline_link_sections, :skyline_sections_link_sections
    rename_table :skyline_rss_sections, :skyline_sections_rss_sections
    rename_table :skyline_splitter_sections, :skyline_sections_splitter_sections
    rename_table :skyline_wysiwyg_sections, :skyline_sections_wysiwyg_sections
    
    sections = %w{Skyline::ContentCollectionSection Skyline::ContentItemSection Skyline::HeadingSection Skyline::IframeSection Skyline::LinkSection Skyline::RssSection Skyline::SplitterSection Skyline::WysiwygSection}
    sections.each do |s|
      n = s.sub("Skyline", "Skyline::Sections")
      execute("UPDATE skyline_associated_tags SET taggable_type='#{n}' WHERE taggable_type='#{s}'")
      execute("UPDATE skyline_sections SET sectionable_type='#{n}' WHERE sectionable_type='#{s}'")
      execute("UPDATE skyline_ref_objects SET refering_type='#{n}' WHERE refering_type='#{s}'")
    end
  end

  def self.down
    raise "cannot be undone"
  end
end
