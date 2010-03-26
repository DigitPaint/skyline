# @abstract Implement this interface in classes that can be used
#   as renderable scopes.
module Skyline::Rendering::Scopes::Interface
  
  # @abstract
  def renderer(options = {})
    raise "renderer(options = {}) must be overridden"
  end

  # @abstract  
  def serialize
    raise "serialize() must be overridden"
  end
  
  # @abstract  
  def self.load_from_serialized_string(serialized_string)
    raise "self.load_from_serialized_string() must be overridden"
  end    
  
  def self.unserialize(serialized_string)
    class_name, params = serialized_string.split("-")
    class_name.constantize.load_from_serialized_string(params.to_s)
  end
  
  def templates_for(klass_or_obj)
    self.renderer.templates_for(klass_or_obj)
  end
  
end