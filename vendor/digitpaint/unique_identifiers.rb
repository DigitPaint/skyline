# Include this Module in your ActiveRecord model
# so you can use unique_identifier :name, :scope => "bla" (see #unique_identifier for more info)


module UniqueIdentifiers
  def self.included(o)
    o.extend(ClassMethods)
    o.send(:cattr_accessor, :_identifiers)
    o.send(:before_save, :process_identifiers)
  end
  
  module ClassMethods
    # Defines a column as an unique identifier. It will automatically ensure
    # that the identifier will be unique. 
    # This will be ensured by adding a number to the identifier if it isn't
    # unique. Ie: test => test_1 => test_2 => ...  until it is unique.
    #
    # ==== Parameters
    # column<Symbol,String>:: The column to make an unique identifier
    # options<Hash>:: Options hash [OPTIONAL]
    #
    # ==== Options
    # :scope:: The scope where we should be unique
    # :default<String,Proc>:: The default value to give if identifier is blank (defaults to "untitled")
    # :sanitize_with:: Sanitize unknown characters to _ (defaults to /[^a-z0-9_]/) if false no sanitation will be done
    def unique_identifier(column,options={})
      options.reverse_merge! :default => "untitled", :sanitize_with => /[^a-z0-9_]/
      
      self._identifiers ||= {}
      self._identifiers[column.to_s] = options
    end
  end
  
  protected
  def process_identifiers
    return if self.class._identifiers.blank?
    self.class._identifiers.each do |column,options|
      process_identifier(column,options)
    end
  end
  
  def default_value(default)
    if default.respond_to?(:call)
      default.call(self)
    else
      default
    end
  end
  
  def process_identifier(column,options)
    self[column] = default_value(options[:default]) if self[column].blank?
    self[column] = self[column].downcase.gsub(options[:sanitize_with], "_").squeeze("_") if options[:sanitize_with]

    something_changed = self.changed.include?(column)

    scope_values = []
    scope = Array(options[:scope]).map do |scope_item|
      case scope_item
      when Symbol
        something_changed ||= self.changed.include?(scope_item.to_s)
        value = self.send(scope_item)
        scope_values << value
        "#{self.class.quoted_table_name}.#{ActiveRecord::Base.connection.quote_column_name(scope_item)} = ?"
      else 
        scope_item
      end
    end

    return unless something_changed
    
    self.class.send(:with_exclusive_scope,:find => {:conditions => [scope.join(" AND "),*scope_values]}) do
      if self.new_record?
        conditions = ["#{self.class.quoted_table_name}.#{ActiveRecord::Base.connection.quote_column_name(column)} = ?", self[column]]
      else
        conditions = ["#{self.class.quoted_table_name}.#{ActiveRecord::Base.connection.quote_column_name(column)} = ? AND id != ?", self[column], self.id]
      end
    
      if self.class.exists?(conditions)
        if parts = self[column].match(/^(.*)_([0-9]+)$/)
          self[column] = "#{parts[1]}_#{parts[2].to_i+1}"
        else
          self[column] = "#{self[column]}_1"
        end
        # recursively check if the identifier is unique now
        process_identifier(column,options)        
      end
    end 
  end
end