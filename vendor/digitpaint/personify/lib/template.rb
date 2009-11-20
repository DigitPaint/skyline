module Personify
  class Template
    
    attr_reader :template
    
    def initialize(template)
      parser = PersonifyLanguageParser.new
      @template = parser.parse(template)
    end
    
    def render(local_assigns={})
      @template.eval(local_assigns)
    end
    
  end
end