class Skyline::Sections::PageFragmentSection < ActiveRecord::Base
  include Skyline::SectionItem

  belongs_to :page_fragment, :class_name => "Skyline::PageFragment"
  
  validates_presence_of :page_fragment_id
end
