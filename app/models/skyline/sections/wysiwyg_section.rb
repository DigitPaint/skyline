class Skyline::Sections::WysiwygSection < ActiveRecord::Base
  include Skyline::SectionItem
  include Skyline::Referable
  
  self.default_interface = false
  
  referable_field :body
  
  def to_text
    HTML::FullSanitizer.new.sanitize(self.body)
  end
end
