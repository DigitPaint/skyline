# @private
class Skyline::Sections::LinkSection < ActiveRecord::Base
  include Skyline::Sections::Interface
  include NestedAttributesPositioning  
  
  has_many :links, :class_name => "Skyline::LinkSectionLink", :dependent => :destroy
  
  validate :has_at_least_one_link
  
  accepts_nested_attributes_for :links, :allow_destroy => true
  attr_accessible :links_attributes, :title
  
  def dup
    super.tap do |dup|
      dup.links = self.links.collect{|link| link.dup}
    end
  end  
  
  protected
  def has_at_least_one_link
    self.errors.add(:links, :no_links) unless self.links.detect{|link| !link.marked_for_destruction?}
  end
end
