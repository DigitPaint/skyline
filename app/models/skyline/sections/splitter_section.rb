# @private
class Skyline::Sections::SplitterSection < ActiveRecord::Base
  include Skyline::SectionItem
  
  self.default_interface = false
end