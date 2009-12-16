# @private
class Skyline::Sections::HeadingSection < ActiveRecord::Base
  include Skyline::SectionItem
  
  self.default_interface = false
end