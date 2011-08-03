# @private
module Skyline::Content
  module Content
    def self.included(obj)
      obj.extend(KlassMethods)
     
       if obj.ancestors.include?( ::ActiveRecord::Base)
         obj.class_eval do 
           after_save :process_after_save
           
           scope :published, lambda {
             if obj.publishable?
               {:conditions => {:published => true}}
             else
               {}
             end
           }

           scope :with_site, {}
         end         
       end
     end 
     
     module KlassMethods  #:nodoc:
    
      def content?
        true
      end
    
      # Does this object have a published field
      def publishable?
        self.column_names.include?("published")
      rescue
        true
      end
    
      # Does this object have tags
      def taggable?
        self.reflect_on_all_associations(:has_many).detect{|a| a.name == :associated_tags}
#      rescue
#        false
      end      
      
      # Is this object filterable? 
      # Basically means wether or not this object has fields with
      # the metadata :filter set to true.
      def filterable?
        self.filterable_fields.any?
      end
    
      # Does this object have a position field
      def orderable?
        false
      end
    
      # Is this object exportable
      def exportable?
        false
      end

      # Is this object importable
      def importable?
        false
      end
    
    
      # Find objects for use in the CMS, these are wrappers
      # for the standard find method of ActiveRecord::Base with
      # some extra options.
      #
      # ==== Parameters
      # See ActiveRecord::Base.find for more info on the standard parameters
      #
      # ==== Options
      # :self_referential<Boolean>:: 
      #   If false, will only find records where the associations to other objects
      #   of the same class are null. Which basically means it get's the top level
      #   of the hierarchy.
      # :filter<Hash>::
      #   
      #--
      def find_for_cms(*args)
        skyline_options,options = extract_all_options!(args)
    
        with_skyline_scope(skyline_options) do
         options.update(:order => self.default_order_by_statement)
         find(*(args << options))
        end
      end
    
      # Same as find_for_cms but this method only returns a count.
      #--
      def count_for_cms(*args)
        skyline_options,options = extract_all_options!(args)        
        with_skyline_scope(skyline_options) do
         count(*(args << options))
        end         
      end
    
      # Same as find_for_cms, but works with the will_paginate plugin
      #--
      def paginate_for_cms(*args)
        skyline_options,options = extract_all_options!(args)        
        with_skyline_scope(skyline_options) do
         options.update(:order => self.default_order_by_statement)
         paginate(*(args << options))
        end         
      end
       
      include FieldMetaData
      include ClassMetaData
      include Orderable 
      include Exportable
      # Versioning::Versionable is added direcly on the class
    
      private
    
      # Extract the skyline specific options from the options hash
      #--
      def extract_all_options!(args)
        options = args.extract_options!
        skyline_options = {}
        [:self_referential,:filter].each do |k|
          v = options.delete(k)
          skyline_options[k] = v unless v.nil?
        end
        [skyline_options,options]
      end
              
       # Self referential associations scope
       def with_skyline_scope(options,&block)
        find_scopes = []         
    
        if options[:self_referential] == false
          conditions = self_referential_associations_conditions
          find_scopes << {:conditions => conditions} if conditions
        end
        
        if options[:filter]
          conditions = extract_filter_options(options[:filter])
          find_scopes << {:conditions => conditions} if conditions
        end
        
        apply_scopes(find_scopes,&block)
      end
      
      def apply_scopes(find_scopes=[],&block)
        return yield if find_scopes.blank?
        return with_scope(:find => find_scopes.first){apply_scopes(find_scopes[1..-1],&block)}
      end
     
      # Special case of self referential associations, these 
      # are associations that point to the same table/class to 
      # create a tree hierarchy for instance.
      #--
      def self_referential_associations
        @self_referential_assocs ||= self.reflect_on_all_associations(:has_many).find_all{|a| a.klass == self}
      end
       
      # Extract only valid filter options. All fields which are not actually
      # filterable will be removed.
      def extract_filter_options(filter)
        return nil unless filter.kind_of?(Hash)
        filter_conditions = {}
        filter.each do |k,v|
          field = self.fields[k.to_sym]
          next if !field || field && !field.filterable || v.blank?
          filter_conditions[field.attribute_name] = v
        end
        filter_conditions
      end
       
      def self_referential_associations_conditions
        return nil if self_referential_associations.empty?
        
        self_referential_associations.collect do |assoc| 
          (assoc.options[:foreign_key] || assoc.primary_key_name).to_s + " is null" 
        end.join(" AND ")
      end
    
    end # Klass Methods
    
    # The label of this object instance by which a
    # human can identify this instance.
     def human_id
      id_columns = [self.class.settings.identification_columns].flatten.compact.find_all{|c| self.respond_to?(c)}
      
      if id_columns.blank?
        self.send(possible_identification_columns.compact.find{|c| self.respond_to?(c)})
      else
        id_columns.map{|c| self.send(c)}.join(" ")
      end
     end
     
     # @deprecated
     alias :identification :human_id 
     
     # List of fallback identification columns if it isn't specified
     # in the implementation: titel, title, naam, name, url, id
     def possible_identification_columns
       %w{titel title naam name url id}
     end     
     
     # Is this object a content object? Delegates to self.class.content?
     def content?
       self.class.content?
     end
     
     def instantiated_by=(type) # :nodoc:
       @type = type
     end
     def instantiated_by # :nodoc:
       @type
     end    
     
     # Set correct relation options for the relationship
     # of self to obj
     def relate_to(obj) # :nodoc:
       return unless assoc = obj.class.reflect_on_association(self.instantiated_by)
       case assoc.macro
         when :has_many : obj.send(self.instantiated_by) << self
         when :has_one : obj.send("#{self.instantiated_by}=",self) 
        end
     end
     
     protected
     
     def process_related_objects(field,values)
       return unless assoc = field.reflection
       case assoc.macro
         when :has_and_belongs_to_many then process_habtm_related_objects(field,values,assoc)
         when :has_many then
           if assoc.through_reflection
             process_has_many_through_related_objects(field,values,assoc)
           else
             process_has_many_related_objects(field,values,assoc)
           end
         else raise "You can't use related objects for #{assoc.macro} on #{self.class}"
       end
     end
     
     def process_habtm_related_objects(field,values,assoc)
       target_order = values.delete("_order") # This is discarded, a HABTM relationship cannot have a positionfield
       target_ids = values.map{|k,v| v["_target_id"].to_i }
       current_ids = self.send("#{field.name.to_s.singularize}_ids")
       if target_ids.sort != current_ids.sort
         objects = assoc.klass.find(target_ids).inject({}){|mem,o|mem[o.id] = o; mem}
         self.send("#{field.name}").clear
         self.send("original_#{field.name}=",target_ids.map{|i| objects[i]})
       end
     end
     
     def process_has_many_through_related_objects(field,values,assoc)
       order_map = {}   
       position_column = nil    
       if (target_order = values.delete("_order")) && assoc.through_reflection.klass.orderable?
         target_order = target_order.split(",").each_with_index{|v,k| order_map[v]=k + 1}
         position_column = assoc.through_reflection.klass.position_column
       end
       
       target_ids = values.map{|k,v| v["_target_id"].to_i }
       current = self.send(assoc.through_reflection.name).inject({}){|mem,o|mem[o.id] = o; mem}
       
       # Removal!
       deletable = (current.keys - values.keys.map(&:to_i))
       self.destroy_associated += current.values_at(*deletable) if deletable.any?
       
       # Add & update
       values.each do |k,v|
         target_id = v.delete("_target_id")
         params = {}
         if tempid = k.to_s[/^n__?(n?\d+)/,1]
           # new
           params.update(assoc.source_reflection.primary_key_name => target_id)
           params.update(position_column => order_map[tempid]) if position_column           
           self.send(assoc.through_reflection.name).build(v.update(params))
         else
           # update join model, don't update target!
           next unless current.has_key?(k.to_i)
           params.update(position_column => order_map[k.to_s]) if position_column
           current[k.to_i].attributes = v.update(params)
           self.save_associated << current[k.to_i] unless self.destroy_associated.include?(current[k.to_i])
         end
       end
     end
     
     def process_has_many_related_objects(field,values,assoc)
       current = self.send(assoc.name).inject({}){|mem,o|mem[o.id] = o; mem}
       
       # Removal!
       deletable = (current.keys - values.keys.map(&:to_i))
       self.destroy_associated += current.values_at(*deletable) if deletable.any?
       
       # Add & update
       values.each do |k,v|
         if tempid = k.to_s[/^n__?(n?\d+)/,1]
           # new
           self.send(assoc.name).build(v)
         else
           next unless current.has_key?(k.to_i)
           current[k.to_i].attributes = v
           self.save_associated << current[k.to_i] unless self.destroy_associated.include?(current[k.to_i])
         end
       end       
     end
     
     def save_associated
       @_save_associated ||= []
     end
     
     def destroy_associated
       @_destroy_associated ||= []
     end
     def destroy_associated=(v)
       @_destroy_associated = v
     end
    
     def process_after_save
       if self.destroy_associated.any?       
         self.destroy_associated.each{|o| o.destroy } 
      end
      if self.save_associated.any?
        self.save_associated.each{|o| o.save unless o.frozen? } 
      end
     end
  end
end
