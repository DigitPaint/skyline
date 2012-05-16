# @private
class Skyline::Sections::HeadingSection < ActiveRecord::Base
  include Skyline::Sections::Interface
  
  attr_accessible :heading
  
  self.default_interface = false
end