class Skyline::LinkSectionLinksController < Skyline::ApplicationController
  def new
    @link = Skyline::LinkSectionLink.new
    @link_guid = Guid.new    
  end
end