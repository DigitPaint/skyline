# @private
class Skyline::Sections::MediaSection < ActiveRecord::Base
  include Skyline::Sections::Interface
  include Skyline::BelongsToReferable
  
  ALIGNMENT = %w{left right block_left block_right block_center}
  
  # The media linked to this section
  belongs_to_referable :media
  
  # An optional link
  belongs_to_referable :link
  
  validates_numericality_of :width, :height, :allow_nil => true
  
  delegate :url, :external?, :to => :media
  
  attr_accessible :alignment, :width, :height, :caption
  
  def width
    self.dimension[0]
  end
  
  def height
    self.dimension[1]
  end
  
  def dimension
    width = self[:width].to_i
    height = self[:height].to_i
    if self.media.present? && self.media.kind_of?(Skyline::MediaNode)
      width = media.width if self[:width].blank?
      height = media.height if self[:height].blank?
      proportional = self.media.proportional_dimension(width,height)
      if proportional
        width,height = proportional
      else
        width,height = self.media.width,self.media.height
      end
    end

    [width,height]
  end
end
