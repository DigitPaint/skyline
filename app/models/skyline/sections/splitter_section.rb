# @private
class Skyline::Sections::SplitterSection < ActiveRecord::Base
  include Skyline::Sections::Interface
  
  self.default_interface = false
end