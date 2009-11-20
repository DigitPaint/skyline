class Skyline::LinkSectionLink < ActiveRecord::Base
  include Skyline::ContentItem
  include Skyline::Positionable
  
  set_table_name :skyline_link_section_links
  
  self.positionable_scope = :link_section_id
  
  referable_content :linked
  delegate :url, :external?, :file?, :blank?, :to => :linked
  
  belongs_to :link_section
  
  validates_presence_of :title
  
  default_scope :order => "position"  
end
