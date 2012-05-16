# @private
class Skyline::Sections::RawSection < ActiveRecord::Base
  include Skyline::Sections::Interface
  
  attr_accessible :body
    
  def to_text
    HTML::FullSanitizer.new.sanitize(self.body)
  end  
end
