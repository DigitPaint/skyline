module Skyline
  # The rootpath of the skyline plugin
  def root
    @@root ||= Pathname.new(File.dirname(__FILE__) + "/../")
  end
  module_function :root
  
  def version
    Skyline::VERSION::STRING
  end
  module_function :version  
end

