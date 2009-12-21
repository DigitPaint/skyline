# @private
class Skyline::Sections::MediaSection < ActiveRecord::Base
  include Skyline::SectionItem
  include Skyline::ContentItem
  
  ALIGNMENT = %w{left right block_left block_right block_center}
  
  # The media linked to this section
  referable_content :media
  
  # An optional link
  referable_content :link
  
  validates_numericality_of :width, :height, :allow_nil => true
  
  delegate :url, :external?, :to => :media
end
