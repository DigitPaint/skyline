class Skyline::RenderableScope < Array
  include Skyline::Rendering::Scopes::Interface

  class << self  
    def from_a(array)
      r = self.new
      array.each do |i|
        r << i
      end
      r
    end
  end
  
  def renderer(options = {})
    # TODO renderer alleen doorsnede laten nemen
    options.merge!(:paths => self.collect{|i| i.template_paths}.flatten, :site => self.first)
    Skyline::Renderering::Renderer.new(options)
  end
    
  def serialize
    "#{self.class.name}-#{self.collect{|i| i.id}.join(",")}"
  end
  
  def self.load_from_serialized_string(serialized_string)
    self.from_a(Skyline::Site.find(serialized_string.split(",")))
  end    
end