# @private
class Skyline::Sections::IframeSection < ActiveRecord::Base
  extend UrlValidation  
  include Skyline::Sections::Interface
  
  validates_numericality_of :width, :height
  validates_presence_of :url
  validates_format_of_url :url, :schemes => %w{http}
end
