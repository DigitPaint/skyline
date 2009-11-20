module Skyline::Content
  module MetaData
    class FieldGroup < Array #:nodoc:
      attr_accessor :name, :owner, :title
  
      def initialize(options)
        super([])
  
        self.name = options[:name]
        self.title = options[:title]
        self.owner = options[:owner]
  
        self.field(options[:field]) if options[:fields] && options[:fields].any?    
      end
  
      def singular_title
        return self.name.to_s.humanize if self.title.blank?
        self.title.kind_of?(Array) && self.title.first || self.title.to_s
      end
  
      def plural_title
        return self.name.to_s.humanize.pluralize if self.title.blank?
        self.title.kind_of?(Array) && self.title.last || self.title.to_s.pluralize
      end
  
      def inspect
        "#<FieldGroup fields=#{super}>"
      end
  
      def field(*fields,&block)
        created_fields = self.owner.field(*fields,&block)
        self.concat(created_fields.map(&:name))
  
        # Remove newly grouped fields from the ungrouped list as well as the existing order
        current_order = self.owner.field_order.dup
        fields.each do |field_name| 
          next unless field_name.kind_of?(Symbol)
  
          self.owner.ungrouped_fields.delete(field_name)
          current_order.delete(field_name)
        end
        self.owner.field_order(*current_order)
  
        created_fields
      end
  
      def each_field(&block)  
        self.each do |field_name|
          yield_field(field_name, &block)
        end      
      end  
  
      def only_each_field_of(selection,&block)
        selection.each do |field_name|
          if self.include?(field_name)          
            yield_field(field_name,&block)
          else
            yield nil
          end
        end    
      end
  
      def field_names
        self.to_a
      end
  
      def columns_hash
        self.owner.columns_hash
      end
      
      # You can't hide groups
      def hidden_in(scope)
        false
      end
  
      private   
      # Checks if the field exists, if it does it yields it otherwise it creates a new one.  
      def yield_field(name,&block)
        self.owner.send(:yield_field,name,&block)
      end    
    end  
  end
end