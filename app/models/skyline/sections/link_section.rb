class Skyline::Sections::LinkSection < ActiveRecord::Base
  include Skyline::SectionItem
  include NestedAttributesPositioning  
  
  has_many :links, :class_name => "Skyline::LinkSectionLink", :dependent => :destroy
  
  validate :has_at_least_one_link
  
  accepts_nested_attributes_for :links, :allow_destroy => true
  
  def clone
    returning super do |clone|
      clone.links = self.links.collect{|link| link.clone}
    end
  end  
  
  protected
  def has_at_least_one_link
    self.errors.add(:links, :no_links) unless self.links.detect{|link| !link.marked_for_destruction?}
  end
end
