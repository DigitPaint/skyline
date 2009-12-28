# @private
class Skyline::Rendering::Scopes::Wildcard
  include Skyline::Rendering::Scopes::Interface

  def renderer(options = {})
    Skyline::Rendering::Renderer.new(options)
  end
    
  def serialize
    "#{self.class.name}-n/a"
  end
  
  def self.load_from_serialized_string(serialized_string)
    self.new
  end    
end