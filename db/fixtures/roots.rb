if !Object.const_defined?(:Rails)
  require File.dirname(__FILE__) + "/../../../../config/environment"
end

# ========================================================================
# = Definition of the required rood MediaDir node =
# ========================================================================

puts "\n== Creating media dir root"
root = Skyline::MediaDir.find_or_create_by_parent_id(nil) do |md|
  md.name = "home"
end

puts "\n== Creating homepage"
root = Skyline::Page.find_or_create_by_parent_id(nil)