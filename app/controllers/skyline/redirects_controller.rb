class Skyline::RedirectsController < Skyline::ApplicationController
  def new
    redirect_to Skyline::Section.find_by_id(params[:redirect_section_id]).sectionable.url(request)
  end
end