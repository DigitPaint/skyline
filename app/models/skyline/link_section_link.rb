# @private
class Skyline::LinkSectionLink < ActiveRecord::Base
  include Skyline::BelongsToReferable
  include Skyline::Positionable
  
  self.table_name = "skyline_link_section_links"
  
  self.positionable_scope = :link_section_id
  
  belongs_to_referable :linked
  delegate :url, :external?, :file?, :blank?, :to => :linked
  
  belongs_to :link_section
  
  validates_presence_of :title
  validate :presence_of_linked
  
  default_scope :order => "position"  
  
  protected
  def presence_of_linked
    self.errors.add :linked, :empty if self.linked.blank? || self.linked.marked_for_destruction?
  end
end
