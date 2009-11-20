# Use this Module in all Skyline Sections and in all custom implementation Sections
#
#
# Usage: 
# class Model < ActiveRecord::Base
#   include Skyline::SectionItem
# end
#
# 
# 1) Sets your models class name to "skyline_sections_#{base.table_name}"
# 
# 2) Gives your Model the following interface:
# 
#    class  Model < ActiveRecord::Base
#      has_one :section, :as => :sectionable, :class_name => "Skyline::Section" 
#     
#      cattr_accessor :default_interface    (defaults to true)
#
#      def to_text                          (returns "")
#    end

module Skyline::SectionItem 
 
  def self.included(base)
    base.class_eval do
      set_table_name "skyline_sections_#{base.table_name}" if base.parents.include?(Skyline)
      has_one :section, :as => :sectionable, :class_name => "Skyline::Section"
    end
    base.send(:cattr_accessor, :default_interface)
    base.send(:default_interface=, true)
  end
  
  # to_text
  # ==== returns 
  # String:: plain text of section
  def to_text
    ""
  end
end