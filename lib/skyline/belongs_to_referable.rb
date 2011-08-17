# Use this Module in in a class that references a Page/MediaFile/URL as an association.
# It adds the class method `belongs_to_referable`. With {Skyline::Referable::ClassMethods#belongs_to_referable} you create a
# `belongs_to` association to an Page/MediaFile/URL through a RefObject.
# 
# @see Skyline::BelongsToReferable::ClassMethods#belongs_to_referable
#
# @example Usage
#
# class Model < ActiveRecord::Base
#   include Skyline::BelongsToReferable
#
#   belongs_to_referable :teaser      # column teaser_id must be available
# end
#
#
# @example Gives your Model the following interface:
#
# class Model < ActiveRecord::Base
#   after_save :possibly_destroy_previous_referables
#   after_destroy :possibly_destroy_referables
#   before_save :set_refering_type_and_id
#   after_create :set_refering_id
#
#   belongs_to :teaser, :class_name => "Skyline::ObjectRef", :foreign_key => "teaser_id", :dependent => :destroy
#   accepts_nested_attributes_for :teaser, :reject_if => proc {|attributes| attributes['referable_type'].blank?}, :allow_destroy => true
#   validates_presence_of :teaser   # only if options[:allow_nil] is not set
#
#   def teaser_with_passthrough=(obj) # obj can be an ObjectRef or a Teaser, in which case it will be passed through
#     # ...
#   end
#   alias_method_chain :teaser=, :passthrough
# end
#
module Skyline::BelongsToReferable 
  def self.included(base)
    base.extend(ClassMethods)

    # Callbacks
    base.send(:before_save, :set_refering_type_and_id)
    base.send(:after_create, :set_refering_id)
    base.send(:after_save, :possibly_destroy_previous_referables)
    base.send(:after_destroy, :possibly_destroy_referables)
    
    base.send(:cattr_accessor, :referable_contents)
    base.send(:attr_accessor, :previous_referables)
    base.send(:alias_method_chain, :clone, :referable_content)
    
    
    base.send("referable_contents=", [])
  end  
  
  module ClassMethods   

    # Defines a relationship to a referable.
    # 
    # @see Skyline::BelongsToReferable For a usage example.
    # 
    # @overload belongs_to_referable(*fields, options = {})
    #   @param *fields [String,Symbol] The referable(s) to create associations to.
    # 
    #   @option options :allow_nil [true, false] (true) Allow this association to be empty?
    # 
    # @return [void]
    def belongs_to_referable(*fields)
      options = fields.extract_options!.reverse_merge(:allow_nil => true)
      fields.each do |f|
        self.referable_contents << f
                
        belongs_to f, :class_name => "Skyline::ObjectRef", :foreign_key => "#{f}_id", :dependent => :destroy
        accepts_nested_attributes_for f, :reject_if => proc {|attributes| attributes['referable_type'].blank?}, :allow_destroy => true

        unless options[:allow_nil]
          # validating on :linked instead of :linked_id here; see:
          #   http://railsforum.com/viewtopic.php?id=30300
          #   https://rails.lighthouseapp.com/projects/8994/tickets/1943
          #   https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2815-nested-models-build-should-directly-assign-the-parent          
          validates_presence_of f
        end

        self.class_eval(<<-END, __FILE__, __LINE__ + 1)
          def #{f}_with_passthrough=(obj)
            if obj.kind_of?(Skyline::ObjectRef)
              self.#{f}_without_passthrough = obj
            else
              self.attributes = {"#{f}_attributes" => {:referable_type => obj.class.name, :referable_id => obj.id}}
            end
          end
          alias_method_chain :#{f}=, :passthrough
          
          def #{f}_attributes=(attributes)
            referable_params = attributes.delete("referable_attributes")
            self.previous_referables ||= {}
            self.previous_referables[:#{f}] = self.#{f}.referable.dup if self.#{f}.andand.referable
            assign_nested_attributes_for_one_to_one_association(:#{f}, attributes)
  
            # only create and modify referable if it is a Skyline::ReferableUri
            if self.#{f} && attributes[:referable_type] == "Skyline::ReferableUri"
              self.#{f}.referable.reload if self.#{f}.referable
              self.#{f}.referable ||= attributes[:referable_type].constantize.new
            
              if referable_params.kind_of?(Hash)
                referable_params.each do |k, v|
                  self.#{f}.send(k.to_s + "=", v) if self.#{f}.respond_to?(k.to_s + "=")
                end
              end
            end
          end          
        END
      end
    end
    
  end
  
  # @private
  def clone_with_referable_content
    clone_without_referable_content.tap do |clone|      
      if self.referable_contents.any?
        self.referable_contents.each do |field|
          if self.send(field).present?
            clone.send("#{field}_id=", nil)
            clone.send("#{field}=", self.send(field).clone)
          end
        end
      end
    end
  end
  
  protected

  def set_refering_type_and_id
    self.referable_contents.each do |field|
      if object_ref = self.send(field) 
        unless object_ref.marked_for_destruction?
          object_ref.refering_type = self.class.name
          object_ref.refering_id = self.id unless self.new_record?
        end
      end
    end
  end
  
  def set_refering_id
    self.referable_contents.each do |field|
      if object_ref = self.send(field) 
        object_ref.update_attribute(:refering_id, self.id) if object_ref.refering_id.blank?
      end
    end
  end
  
  def possibly_destroy_previous_referables
    return unless self.previous_referables
    self.previous_referables.each do |field, previous_referable|
      if previous_referable != self.send(field).referable
        previous_referable.destroy if previous_referable.kind_of?(Skyline::ReferableUri)
      end
    end
  end
  
  def possibly_destroy_referables
    self.referable_contents.each do |field|
      if object_ref = self.send(field) 
        object_ref.destroy if object_ref.kind_of?(Skyline::ReferableUri)
      end      
    end
  end
end

