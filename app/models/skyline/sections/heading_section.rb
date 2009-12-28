# @private
class Skyline::Sections::HeadingSection < ActiveRecord::Base
  include Skyline::Sections::Interface
  
  self.default_interface = false
end