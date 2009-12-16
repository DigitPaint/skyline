# @private
class Skyline::Sections::MediaSection < ActiveRecord::Base
  include Skyline::SectionItem
  include Skyline::ContentItem
  
  ALIGNMENT = %w{left right block_left block_right block_center}
  
  referable_content :linked

  validates_numericality_of :width, :height, :allow_nil => true
  
  delegate :url, :external?, :to => :linked
end
