module Skyline::Content
  module MetaData
    class ClassSettings < Field #:nodoc:
  
      def singular_label
        singular(self.label,self.klass.to_s.demodulize.underscore.humanize)
      end
      def plural_label
        plural(self.label,self.klass.to_s.demodulize.underscore.humanize.pluralize)    
      end
  
  
      # Klass these ClassSettings belong to
      def klass; self.owner; end  
  
    end
  end
end