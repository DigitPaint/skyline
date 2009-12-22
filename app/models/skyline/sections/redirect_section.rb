# @private
class Skyline::Sections::RedirectSection < ActiveRecord::Base
  include Skyline::Sections::Interface
  include Skyline::BelongsToReferable
  
  belongs_to_referable :linked
  
  validates_numericality_of :delay

  def url(request)
    if self.linked.external? 
      self.linked.url
    else
      request.protocol + request.host_with_port + self.linked.url
    end
  end
end
