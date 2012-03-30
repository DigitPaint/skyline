require 'pathname'
require File.dirname(__FILE__) + "/skyline/version"

# The Skyline contains all Skyline related (core) code and
# defines some methods like the root (path) and version
# of the Skyline core.
module Skyline
  
  # The root of the Skyline tree.
  #
  # @return [Pathname] 
  def root
    @@root ||= Pathname.new(File.dirname(__FILE__) + "/../")
  end
  module_function :root
  
  # Shortcut for the current version
  #
  # @return [String] The current version in the format x.x.x.x (the BUILD version is optional)
  def version
    Skyline::VERSION::STRING
  end
  module_function :version  
  
  # The table name prefix for Skyline
  # TODO: currently set to "" because we do this manually in all models. We have to remove all manually set table name prefix and use this one instead.
  def table_name_prefix
    ""
  end
  module_function :table_name_prefix  
  
end

