module Skyline

  # @deprecated  
  module ContentItem
    
    def self.included(base)
      warn "[DEPRECATION] Don't use Skyline::ContentItem anymore, use Skyline::BelongsToReferable"
      
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
      warn "[DEPRECATION] Don't use Skyline::Referable anymore, use Skyline::HasManyReferablesIn"
            
      base.send(:include, Skyline::HasManyReferablesIn)
      class << base 
        alias_method :referable_field, :has_many_referables_in
      end      
    end
  end
  
  # @deprecated  
  module SectionItem
    def self.included(base)
      warn "[DEPRECATION] Don't use Skyline::SectionItem anymore, use Skyline::Sections::Interface"
      
      base.send(:include, Skyline::Sections::Interface)
    end
  end
  
  # @deprecated
  module FormBuilderWithErrors
    def self.included(base)
      warn "[DEPRECATION] Don't use Skyline::FormBuilderWithErrors anymore, use Skyline::FormBuilder"
      
      base.send(:include, Skyline::FormBuilder)
    end
  end
    
end
