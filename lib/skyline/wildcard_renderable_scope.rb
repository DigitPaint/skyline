class Skyline::WildcardRenderableScope
  include Skyline::RenderableScopeInterface

  def renderer(options = {})
    Skyline::Renderer.new(options)
  end
    
  def serialize
    "#{self.class.name}-n/a"
  end
  
  def self.load_from_serialized_string(serialized_string)
    self.new
  end    
end