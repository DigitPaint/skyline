module Skyline::Content
  module MetaData
    require 'ostruct'
  
    class Field < OpenStruct #:nodoc:
  
      class << self
        def from(field,options)
          table = field.instance_variable_get(:@table)
          options.delete(:name)
          new(table.dup.update(options))
        end
      end
      
      def initialize(*params)
        super(*params)
        
        # Set implicit association data.
        if self.owner_class && reflection = self.owner_class.reflect_on_association(self.name)
          self.reflection = reflection
          self.hidden = [:edit,:create] unless self.editor || !self.hidden.nil?
        end
        
        # Check if this was a filterable field and check if:
        # * this field is a column
        # * this field is a belongs_to association
        if self.respond_to?(:filterable) && self.filterable && (!self.owner_class.column_names.include?(self.name.to_s) && (!self.association? || self.reflection.macro != :belongs_to))
          raise ArgumentError, "Cannot use filter on non-database field."
        end
        
        # Set default editors if it's not set but type is available
        if !self.respond_to?(:editor) || self.editor.blank?
          self.editor = {
            :string => :text_field,
            :boolean => :boolean,
            :datetime => :date_time,
            :timestamp  => :date_time,
            :date => :date,
            :text => :textarea
          }[self.type]
        end
      end
      
      def singular_title
        singular(self.title,self.singular_label)
      end
      def plural_title
        plural(self.title,self.plural_label)
      end
      def singular_label(alt=self.name)
        singular(self.label,alt)
      end
      def plural_label(alt=self.name)
        plural(self.label,alt)    
      end
  
      def singular(value,alternative=nil)
        return alternative.to_s.humanize if value.nil?    
        value.kind_of?(Array) && value.first || value.to_s
      end
  
      def plural(value,alternative=nil)
        return alternative.to_s.humanize.pluralize if value.nil?    
        value.kind_of?(Array) && value.last || value.to_s.pluralize
      end
      
      # Is this field an association
      #
      # ==== Returns
      # Boolean:: Wether or not this is an association
      #--
      def association?
        self.respond_to?(:reflection) && !self.reflection.nil?
      end
      
      # The ActiveRecord::Column object this field is related to.
      # If empty this can be a virtual field or a field defined through a method.
      # 
      # ==== Returns
      # ActiveRecord::Column,nil:: The column object if any.
      #--
      def column
        self.owner && self.owner.respond_to?(:columns_hash) && self.owner.columns_hash[self.name.to_s]
      end
      
      # Gets all unique values for this field on the owner_class.
      # Returns arrays usable in select/options_for_select helpers.
      # 
      # ==== Returns
      # Array[String,Array[Integer,String]]:: Array of values. If this is an association we get an array of [id,title]
      #--
      def unique_values
        if self.association?
          self.reflection.klass.find(:all).map{|a| [a.human_id,a.id] }
        else
          self.owner_class.connection.select_values("SELECT DISTINCT(#{self.name}) FROM #{self.owner_class.table_name}")
        end
      end        
      
      # The method/column name this field writes to. This takes foreign_keys of belongs_to associations in account.
      def attribute_name
        self.association? && self.reflection.macro == :belongs_to && self.reflection.foreign_key || self.name
      end
      
      # The type of the associated column, or if it's serialized
      # the type that this serialized field was defined as.
      #
      # ==== Returns
      # Symbol:: 
      #   The type name can by any of:
      #    *  :string   
      #    *  :text     
      #    *  :integer  
      #    *  :float    
      #    *  :decimal  
      #    *  :datetime 
      #    *  :timestamp
      #    *  :time     
      #    *  :date     
      #    *  :binary   
      #    *  :boolean
      #--
      def type
        type = method_missing(:type)
        if type.kind_of?(Class) || type.blank?
          self.column && self.column.type
        else
          type
        end
      end
      
      def owner
        method_missing(:owner)
      end
      
      def owner_class
        if self.owner && self.owner.kind_of?(Class) && self.owner.ancestors.include?(ActiveRecord::Base)
          self.owner
        elsif self.owner
          # This is a group so we get the group's owner
          self.owner.owner
        end
      end
      
      def value(record)
        raise(ArgumentError, "The record class (#{record.class}) and the field class (#{self.owner_class}) do not match") if !record.kind_of?(self.owner_class)
        raise(ArgumentError, "The record does not respond do this field name (#{self.name})") unless record.respond_to?(self.name)
        record.send(self.name)
      end
  
      def attribute_value(record)
        raise(ArgumentError, "The record class (#{record.class}) and the field class (#{self.owner_class}) do not match") if !record.kind_of?(self.owner_class)
        raise(ArgumentError, "The record does not respond do this field name (#{self.name})") unless record.respond_to?(self.name)
        record.send(self.attribute_name)      
      end
  
      def hidden_in(scope)
        self.respond_to?(:hidden) && (self.hidden == true || self.hidden.include?(scope))      
      end
  
      def update(options={})
        options.each{|value, key| self.send("#{key}=",value)}
      end
  
      # Functions below only needed on fields with serialized attributes
      def klass
        case self.type
          when :integer       then Fixnum
          when :float         then Float
          when :decimal       then BigDecimal
          when :datetime      then Time
          when :date          then Date
          when :timestamp     then Time
          when :time          then Time
          when :text, :string then String
          when :binary        then String
          when :boolean       then Object
          else nil
        end
      end  
  
      # Casts value (which is a String) to an appropriate instance. Only needed
      # on fields that are in serialized data.
      def type_cast(value)
        return nil if value.nil?
        case self.type
          when :string    then value
          when :text      then value
          when :integer   then value.to_i rescue value ? 1 : 0
          when :float     then value.to_f
          when :decimal   then ActiveRecord::ConnectionAdapters::Column.value_to_decimal(value)
          when :datetime  then ActiveRecord::ConnectionAdapters::Column.string_to_time(value)
          when :timestamp then ActiveRecord::ConnectionAdapters::Column.string_to_time(value)
          when :time      then ActiveRecord::ConnectionAdapters::Column.string_to_dummy_time(value)
          when :date      then ActiveRecord::ConnectionAdapters::Column.string_to_date(value)
          when :binary    then ActiveRecord::ConnectionAdapters::Column.binary_to_string(value)
          when :boolean   then ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
          else value
        end
      end
      
      def inspect
        "<Field @table=#{@table.inspect}>"
      end
      
      def to_param
        self.name
      end
          
    end
  end
end