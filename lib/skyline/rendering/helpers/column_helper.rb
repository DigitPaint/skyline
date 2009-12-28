module Skyline::Rendering::Helpers::ColumnHelper
  
  # Devides the sections into columns depending on splitter location
  #
  # @param page_version [ArticleVersion] The ArticleVersion to get section from to split
  #
  # @return [Array<Array<Section>>] An array of columns each containing and array of sections.
  def sections_per_column(page_version)
    sections_per_col ||= []
    col = 0
    page_version.sections.each do |section|
      if section.sectionable_type == "Skyline::Sections::SplitterSection" 
        col += 1
      else
        sections_per_col[col] ||= []
        sections_per_col[col].push(section)
      end
    end
    sections_per_col
  end
  
  # @deprecated Will be removed in 3.1 for the more general sections_per_column
  alias :page_sections_per_column :sections_per_column
    
end