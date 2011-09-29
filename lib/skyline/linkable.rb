# If included the object will be linkable 
# currently only works on Articles
module Skyline::Linkable
  
  class << self
    def linkables
      Skyline::Configuration.articles.select{|c| c < Skyline::Linkable }
    end
  end

  def self.included(base)
    raise(TypeError, "Expected #{base.inspect} to be a subclass of Skyline::Article") unless base < Skyline::Article
    
    class << base
      def linkable?; true; end
    end
    
  end
  
  # The URL this linkable can be found on. Needed to create the link
  # 
  # @return String The URL
  # @abstract Implement in subclass
  def url
    raise "Implement in subclass"
  end  
  
end