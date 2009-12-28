# @private
class Skyline::Sections::RawSection < ActiveRecord::Base
  include Skyline::Sections::Interface
    
  def to_text
    HTML::FullSanitizer.new.sanitize(self.body)
  end  
end
