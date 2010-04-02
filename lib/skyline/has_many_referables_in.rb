# Use this module in all models that have references to MediaFiles/Page/URL etc via WYSWIWYG-editors
# It adds the class method `has_many_referables_in`. With {Skyline::HasManyReferablesIn::ClassMethods#has_many_referables_in} you can use any
# text/string database field to have links/images that will refer correctly to their respective
# targets through RefObject
# 
# @see Skyline::BelongsToReferable If you want to use a reference to a MediaFile/Page/URL directly as an association.
#
# @example Usage: 
#   class Model < ActiveRecord::Base
#     include Skyline::HasManyReferablesIn
#     has_many_referables_in :body # :body is a database text/string field
#   end
#
# @example Defines:
#   @model = Model.new
#   @model.body = "text <a href='http://www.google.com'>test</a>"
#   @model.body_before_typecast #=> The unconverted value which still includes [REF:XX] tags.
#   @model.body #=> Evertyhing is converted back to it's original state
#   @model.body(true) #=> The HTML includes extra attributes used for editing in the WYSIWYG-editor
#
module Skyline::HasManyReferablesIn 
 
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:before_save, :parse_referable_fields)
    
    # Attention! We have to call it twice so it won't muck up when you create your own after_create/after_save
    # callbacks.
    base.send(:after_create, :update_referable_objects)    
    base.send(:after_save, :update_referable_objects)
    
    base.send(:cattr_accessor, :referable_fields)
    
    base.send(:has_many, :image_refs, :class_name => "Skyline::ImageRef", :foreign_key => :refering_id, :source_type => base.name, :dependent => :destroy)
    base.send(:has_many, :link_refs, :class_name => "Skyline::LinkRef", :foreign_key => :refering_id, :source_type => base.name, :dependent => :destroy)
    
    base.send :alias_method_chain, :clone, :referables    
  end
  
  module ClassMethods    
    
    
    # Make one or more fields/columns have support for referable content in HTML.
    #
    # Overwrites the models accessors for the specified fields/columns. It also adds
    # extra options to the reader. The reader accepts two parameters: `edit` (Boolean) and
    # an options string which is passed to {Skyline::InlineRef#convert}
    #
    # @param fields [String,Symbol] The field(s) to enable the referable content for.
    def has_many_referables_in(*fields)      
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
  
  # Implementation of the clone interface
  # @private
  def clone_with_referables
    returning clone_without_referables do |clone|      
      if !self.referable_fields.nil?
        self.referable_fields.each do |field|         
          clone.send("#{field}=".to_sym, self.send(field,true,{:nullify => true}))
        end
      end
    end
  end

  # @private  
  # @todo Shouldn't this be protected?  
  def referable_field_bodies
    @referable_field_bodies ||= {}
  end
        
  # @private
  # @todo Shouldn't this be protected?    
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
  
  # @private
  # @todo Shouldn't this be protected?  
  def update_referable_objects
    return if self.referable_fields.nil? || @updated_ids.blank?
    Skyline::InlineRef.update_all({:refering_id => self.id}, "id IN(#{@updated_ids})")
    @updated_ids = ""
  end
  
end
