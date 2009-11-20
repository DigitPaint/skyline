class Skyline::Section < ActiveRecord::Base
  set_table_name :skyline_sections
  
  belongs_to :variant, :class_name => "Skyline::Variant"
  belongs_to :article_version, :class_name => "Skyline::ArticleVersion"
  belongs_to :sectionable, :polymorphic => true, :dependent => :destroy

  accepts_nested_attributes_for :sectionable
  
  validates_presence_of :sectionable
  
  default_scope :order => "position ASC"
  
  def build_sectionable(sectionable_attributes)
    params = sectionable_attributes.dup
    raise ArgumentError, "Missing class parameter when building sectionable" unless params["class"]
    klass = params.delete("class")
    self.sectionable = klass.constantize.new(params)
  end
  
  def clone
    returning super do |clone|
      clone.sectionable = self.sectionable.clone
    end
  end  
  
  # to_text
  # ==== returns 
  # String:: plain text of section
  def to_text
    self.sectionable.to_text
  end 
end
