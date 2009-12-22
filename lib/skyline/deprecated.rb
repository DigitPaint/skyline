module Skyline

  # @deprecated  
  module ContentItem
    
    def self.included(base)
      base.send(:include, Skyline::BelongsToReferable)
      
      base.class_eval do
        named_scope(:published, {}) unless method_defined?(:published)
        
        named_scope(:with_site, {}) unless method_defined?(:with_site)
      end
      
      class << base 
        alias_method :referable_content, :belongs_to_referable
      end
    
    end    
  end
  
  # @deprecated
  module Referable
    def self.included(base)
      base.send(:include, Skyline::HasManyReferablesIn)
      class << base 
        alias_method :referable_field, :has_many_referables_in
      end      
    end
  end
  
  # @deprecated  
  module SectionItem
    def self.included(base)
      base.send(:include, Skyline::Sections::Interface)
    end
  end
  
  # 
  # module SectionItem
  # end
  # 
  # module FormBuilderWithErrors
  # end
  
end
