# @private
class Skyline::ReferableUri < ActiveRecord::Base
  self.table_name = "skyline_referable_uris"
  
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
end
