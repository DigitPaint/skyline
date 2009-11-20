module Skyline::Content
  module MetaData
    class FieldPage #:nodoc:
  
      attr_reader :owner,:name,:options
  
      def initialize(owner,name,options={})
        @owner = owner
        @name = name
        @options = options
        @fields = {}
        @ungrouped_fields = []
      end
  
      def description(v=nil)
        @options[:description] = v if v
        @options[:description]
      end
      
      def title(v=nil)
        @options[:title] = v if v
        @options[:title]
      end
  
      def each_field(&block)
        self.ungrouped_fields.each do |field_name|
          yield_field(field_name,&block)
        end
      end
  
      def yield_field(field_name,&block)
        yield self.fields[field_name]
      end
  
      def field(*fields,&block)
        options = fields.last.kind_of?(Hash) ? fields.pop : {}
        fields = fields.first if fields.any? && fields.first.kind_of?(Array)
  
        fields.map do |name|
          @fields[name] = Field.new(options.update(:name => name, :owner => self))
          yield @fields[name] if block_given?
          @ungrouped_fields << name
          @fields[name]
        end
      end
  
      def field_group(name,options={})
        field_group = FieldGroup.new(options.update(:owner => self, :name => name))
        yield field_group if block_given?
        @fields[name] = field_group
        @ungrouped_fields << name
      end
  
      def fields
        @fields
      end
  
      def field_order(*order)
        if order.empty?
          @ungrouped_fields
        else
  
        end
      end
  
      def ungrouped_fields
        @ungrouped_fields
      end
  
      def field_names
        @fields.keys
      end
  
      def human_name
        self.title.present? ? self.title : self.name.to_s.humanize
      end
  
      def owner; @owner; end
  
    end  
  end
end