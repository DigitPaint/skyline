# @private
class Skyline::ReferableUri < ActiveRecord::Base
  self.table_name = "skyline_referable_uris"
  
  before_save :clean_uri
  
  attr_accessor :allow_protocols
  
  def url(*args)
    self.uri
  end
  
  # used in ref_object_helper
  def title
    self.uri
  end

  def external?
    # definition of the URL scheme: http://labs.apache.org/webarch/uri/rfc/rfc3986.html#scheme
    self.uri.present? && self.uri =~ /^[a-z][a-z0-9\+\-\.]*:/i
  end
  
  protected
  
  def clean_uri
    if self.allow_protocols.present?
      del = if URI.unescape(self.uri.downcase) =~ /\A([^\/]*?)(?:\:|&#0*58|&#x0*3a)/i
        !allow_protocols.include?($1.downcase)
      else
        !allow_protocols.include?(:relative)
      end
      
      self.uri = "" if del
    end
  end
  
end
