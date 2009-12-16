# @private
class Skyline::Sections::RawSection < ActiveRecord::Base
  include Skyline::SectionItem
    
  def to_text
    HTML::FullSanitizer.new.sanitize(self.body)
  end  
end
