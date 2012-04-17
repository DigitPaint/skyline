# Usage: 
# class Model < ActiveRecord::Base
#   include Skyline::Taggable
# end
#
# 
# 1) Registers your model in the Skyline::Tag.taggable_models list
# 
# 2) Gives your Model the following interface:
# 
#    class  Model < ActiveRecord::Base
#      has_many :associated_tags, :class_name => "Skyline::AssociatedTag", :as => "taggable"
#      has_many :tags, :through => :associated_tags, :class_name => "Skyline::Tag"    
#     
#      scope :with_tags (tags)      (scope to return items that have at least one of the tags supplied; or all if no tags are passed)
#
#      def raw_tags 
#      def raw_tags=(str)
#      def available_tags
#    end

module Skyline::Taggable 
  def self.included(base)
    Skyline::Tag.register_taggable_model(base)
    
    base.extend(ClassMethods)
    base.send :has_many, :associated_tags, :class_name => "Skyline::AssociatedTag", :as => "taggable"
    base.send :has_many, :tags, :through => :associated_tags, :class_name => "Skyline::Tag"    
    base.send :cattr_accessor, :taggable_type
    
    base.send :alias_method_chain, :dup, :associated_tags
    
    base.send :scope, :with_tags, lambda {|tags|
      if tags.any?
        {:conditions => ["(SELECT tag_id FROM skyline_associated_tags WHERE taggable_id=#{base.table_name}.id AND taggable_type=? AND tag_id IN (?) LIMIT 1)", base.name, tags],
         :include => :associated_tags}
      else
        {}
      end
    }       
  end
  
  def raw_tags
    self.tags.collect{|t| t.tag}.join(" ")
  end
  
  def raw_tags=(str)
    self.tags.clear
    if str.present?
      str.split.each do |t|
        tag = Skyline::Tag.find_or_create_by_taggable_type_and_tag(self.tag_taggable_type, t)
        self.tags << tag unless self.tags.include?(tag)
      end
    end
  end
  
  def available_tags
    self.class.available_tags
  end
  
  def dup_with_associated_tags
    dup_without_associated_tags.tap{|dup|
      dup.associated_tags = self.associated_tags.collect{|at| at.dup }
    }
  end  
  
  protected
  def tag_taggable_type
    if self.taggable_type
      self.taggable_type.call(self)
    else
      self.class.to_s
    end
  end
  
  module ClassMethods
    def available_tags
      Skyline::Tag.find_all_by_taggable_type(self.to_s)
    end
    
    def taggable_scope(scope)
      self.taggable_type = scope
    end
  end
end
