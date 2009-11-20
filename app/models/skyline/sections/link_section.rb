class Skyline::Sections::LinkSection < ActiveRecord::Base
  include Skyline::SectionItem
  include NestedAttributesPositioning  
  
  has_many :links, :class_name => "Skyline::LinkSectionLink", :dependent => :destroy
  
  accepts_nested_attributes_for :links, :allow_destroy => true
  
  def clone
    returning super do |clone|
      clone.links = self.links.collect{|link| link.clone}
    end
  end  
end


        
