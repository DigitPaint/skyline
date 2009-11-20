# Use this module in all models that have references to MediaFiles/Pages etc via WYSWIWYG-editors
#
# Usage: 
# class Model < ActiveRecord::Base
#   include Skyline::Referable
# 
#   referable_field :body
# end
#
# 
# 1) Gives your Model the following interface:
# 
#    class  Model < ActiveRecord::Base
#      before_save :parse_referable_fields
#      after_save :update_referable_objects
#      has_many :image_refs, :class_name => "Skyline::ImageRef", :foreign_key => :refering_id, :source_type => "Model", :dependent => :destroy
#      has_many :link_refs,  :class_name => "Skyline::LinkRef",  :foreign_key => :refering_id, :source_type => "Model", :dependent => :destroy
#
#      def body=(body)
#      def body_before_typecast
#      def body(edit = false, options={})
#    end


module Skyline::Referable 
 
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:before_save, :parse_referable_fields)
    base.send(:after_save, :update_referable_objects)
    base.send(:cattr_accessor, :referable_fields)
    base.send(:has_many, :image_refs, :class_name => "Skyline::ImageRef", :foreign_key => :refering_id, :source_type => base.name, :dependent => :destroy)
    base.send(:has_many, :link_refs, :class_name => "Skyline::LinkRef", :foreign_key => :refering_id, :source_type => base.name, :dependent => :destroy)
  end
  
  module ClassMethods    
    
    def referable_field(*fields)      
      self.referable_fields ||= []
      
      fields.each do |f|
        self.referable_fields << f
        
        self.class_eval <<-END
          def #{f}=(body)
            self.referable_field_bodies[:#{f}] = body            
          end
          def #{f}_before_typecast
            self.referable_field_bodies[:#{f}] || self[:#{f}]
          end
          def #{f}(edit = false, options={})
            options.reverse_merge! :nullify => false
            ret = self.referable_field_bodies[:#{f}].nil? ? Skyline::InlineRef.convert(self,:#{f},edit,options) : self.referable_field_bodies[:#{f}]
          end
        END
      end
    end
  end
  
  def clone
    returning super do |clone|      
      if !self.referable_fields.nil?
        self.referable_fields.each do |field|         
          clone.send("#{field}=".to_sym, self.send(field,true,{:nullify => true}))
        end
      end
    end
  end
  
  def referable_field_bodies
    @referable_field_bodies ||= {}
  end
        
  def parse_referable_fields  
    return if self.referable_fields.nil?    
      
    updated_refs = []
    self.referable_fields.each do |col|      
      if new_body = self.referable_field_bodies.delete(col)
        self[col], refs = Skyline::InlineRef.parse_html(new_body, self, col)
        updated_refs += refs
      end
    end
        
    @updated_ids = updated_refs.join(",")
  end
  
  def update_referable_objects
    return if self.referable_fields.nil?
    Skyline::InlineRef.update_all({:refering_id => self.id}, "id IN(#{@updated_ids})") unless @updated_ids.blank?
  end
  
end
