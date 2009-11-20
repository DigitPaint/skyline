module Skyline::Content
  module Orderable
    
    def acts_as_orderable(options)
      config = {:column => "position", :scope => "1 = 1"}
      config.update(options) if options.kind_of?(Hash)
      
      config[:scope] = "#{config[:scope]}_id".intern if config[:scope].is_a?(Symbol) && config[:scope].to_s !~ /_id$/

      class << self; self; end.class_eval do
        define_method(:orderable?){true}
        define_method(:position_column) do
          config[:column]
        end
        define_method(:position_scope) do
          config[:scope]
        end
      end
      
      include Skyline::Content::Orderable::InstanceMethods
      if config[:scope].is_a?(Symbol)
        define_method(:position_scope_condition) do
          if (value = self.send(self.class.position_scope)).nil?
            "#{self.class.position_scope} IS NULL"
          else
            "#{self.class.position_scope} = #{value}"
          end            
        end
      else
        define_method(:position_scope_condition) do
          config[:scope]
        end
      end        

      self.before_create :set_initial_position
      self.sort_order [:position,:asc],[:id,:asc]      
    end
    
    
    # Accepts a list of ids which will then
    # be put in the order they are provided by 
    # keeping the positions and reshuffling them
    def reorder(*ids)
      ids.flatten!
      objects = find_all_by_id(ids)
      return false if ids.size != objects.size
      
      positions = objects.collect{|o| o[self.position_column] || o.id }
      positions.sort!
            
      objects.each do |object|
        idx = ids.index(object.id)
        unless positions[idx] == object[self.position_column]
          object.update_attribute(self.position_column,positions[idx]) 
        end
      end
    end
              
    module InstanceMethods
      def set_initial_position
        unless self[self.class.position_column]
          self[self.class.position_column] = self.current_bottom_position + 1
        end
      end
      
      protected
      
      # Overriden by setting :scope
      def position_scope_condition
        "1"
      end
      
      def current_bottom_position
        conditions = position_scope_condition
        self.class.connection.select_value("SELECT #{self.class.position_column} FROM #{self.class.table_name} WHERE #{conditions} ORDER BY #{self.class.position_column} DESC LIMIT 1").to_i
      end
    end
  end # Orderable
end