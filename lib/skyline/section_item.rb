# Defines the SectionItem interface. Include this module in all your sections.
#
# If you're creating your Section within the Skyline module (you probably shouldn't), it
# will automatically sets your models table name to `skyline_sections_#{base.table_name}`
#
# @example Usage: 
#   class Model < ActiveRecord::Base
#     include Skyline::SectionItem
#   end
#
# @example Defines:
#   Model.default_interface = true # defaults to true
#   @model = Model.new
#   @model.to_text #=> ""
#
module Skyline::SectionItem 
 
  def self.included(base)
    base.class_eval do
      set_table_name "skyline_sections_#{base.table_name}" if base.parents.include?(Skyline)
      has_one :section, :as => :sectionable, :class_name => "Skyline::Section"
    end
    base.send(:cattr_accessor, :default_interface)
    base.send(:default_interface=, true)
  end

  # The to_text method is needed for searching and other string operations which
  # just want the content of this section without any markup.
  # 
  # @return [String] The section's content flattened to only text
  # @abstract Implement in your own section
  def to_text
    ""
  end
end