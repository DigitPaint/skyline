class Skyline::Sections::ContentCollectionSection < ActiveRecord::Base
  include Skyline::SectionItem
  include Skyline::Taggable
  taggable_scope lambda{|ccs| ccs.content_type}
  
  validates_presence_of :content_type
  validates_numericality_of :number, :greater_than => 0
  
  def content_class
    @content_class ||= self.content_type.constantize    
  end
  
  def content_name
    if self.content_class.name.demodulize == "Data" 
      self.content_class.parent.name.underscore 
    else
      self.content_class.name.underscore 
    end    
  end
  
  def clone
    returning super do |clone|
      clone.associated_tags = self.associated_tags.collect{|associated_tag| associated_tag.clone}
    end
  end  
end
