# @private
class Skyline::Section < ActiveRecord::Base
  self.table_name = "skyline_sections"
  
  belongs_to :variant, :class_name => "Skyline::Variant"
  belongs_to :article_version, :class_name => "Skyline::ArticleVersion"
  belongs_to :sectionable, :polymorphic => true, :dependent => :destroy

  accepts_nested_attributes_for :sectionable
  
  validates_presence_of :sectionable
  
  default_scope :order => "position ASC"
  
  def build_sectionable(*params, &block)
    attrs = params.first.dup
    raise ArgumentError, "Missing class parameter when building sectionable" unless attrs["class"]
    klass = attrs.delete("class")
    self.sectionable = klass.constantize.new(attrs)
  end
  
  def dup
    super.tap do |dup|
      dup.sectionable = dup.sectionable.dup
    end
  end  
  
  # to_text
  # ==== returns 
  # String:: plain text of section
  def to_text
    self.sectionable.to_text
  end 
end
