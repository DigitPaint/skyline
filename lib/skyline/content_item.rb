# Use this Module in in a class that references a Page/MediaFile etc throug an ObjectRef
#
#
# Usage: 
# class Model < ActiveRecord::Base
#   include Skyline::ContentItem
# 
#   referable_content :teaser      (column teaser_id must be crreated)
# end
#
# 
# 1) Gives your Model the following interface:
# 
#    class Model < ActiveRecord::Base
#      before_save :set_refering_type_and_id
#      after_create :set_refering_id
#      named_scope :published             (scope to return only published items)
#
#      def referable_content(*fields)
#
#      belongs_to :teaser, :class_name => "Skyline::ObjectRef", :foreign_key => "teaser_id", :dependent => :destroy
#      accepts_nested_attributes_for :teaser, :reject_if => proc {|attributes| attributes['referable_type'].blank?}, :allow_destroy => true
#      [validates_presence_of :teaser     (only if options[:allow_nil] is not set)]
#     
#      def teaser_with_passthrough=(obj)            (obj can be an ObjectRef or a Teaser, in which case it will be passed through)
#      alias_method_chain :teaser=, :passthrough
#    end
#
#
# ***** OR *****
#
# it can be used to reference a Page/MediaFile etc directly when the foreign key must be serialized (or isn't available as an association)
#
# Usage: 
# class Settings < ActiveRecord::Base
#   include Skyline::ContentItem
# 
#   referable_serialized_content  :results_page      (obj.results_page_id and obj.results_page_id= must be available)
# end
#
# 
# 1) Gives your Settings the following interface:
# 
#    class Settings < ActiveRecord::Base
#      def referable_serialized_content(*fields)
#
#      def results_page_attributes=       (set results_page_id to the referable_id; bypassing an ObjectRef)
#    end

module Skyline::ContentItem 
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:before_save, :set_refering_type_and_id)
    base.send(:after_create, :set_refering_id)
    base.send(:cattr_accessor, :referable_contents)
    base.send(:attr_accessor, :previous_referables)
    base.send(:alias_method_chain, :clone, :referable_content)
    base.send(:after_save, :possibly_destroy_previous_referables)
    base.send(:after_destroy, :possibly_destroy_referables)
    
    base.send("referable_contents=", [])
    
    base.class_eval do
      
      named_scope :published, lambda {
        if self.respond_to?(:publishable?) && self.publishable?
          {:conditions => {:published => true}}
        elsif self.ancestors.include?(Skyline::Article::Data)
          {:include => self.table_name.sub("_data", "").to_sym,
           :conditions => "skyline_articles.published_publication_data_id = #{self.table_name}.id"}
        else
          {}
        end
      }

      named_scope :with_site, lambda {|site|
        if site && self.ancestors.include?(Skyline::Article::Data)
          site.named_scope_with_site_for(self)
        else
          {}
        end
      }
    end
  end  
  
  module ClassMethods   

    # accepts options as the last parameter
    #   options[:allow_nil] = true/false    (default: true)
    def referable_content(*fields)
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
            assign_nested_attributes_for_one_to_one_association(:#{f}, attributes, true)
  
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
    
    def referable_serialized_content(*fields)
      fields.each do |f|
        self.class_eval <<-END
          def #{f}_attributes=(attr)
            self.#{f}_id = attr[:referable_id]
          end
        END
      end
    end
  end
  
  def set_refering_type_and_id
    self.referable_contents.each do |field|
      if object_ref = self.send(field)
        object_ref.refering_type = self.class.name
        object_ref.refering_id = self.id unless self.new_record?
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
  
  def clone_with_referable_content
    returning clone_without_referable_content do |clone|      
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

