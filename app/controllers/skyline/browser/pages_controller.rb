class Skyline::Browser::PagesController < Skyline::ApplicationController
  def index
    @pages = Skyline::Page.group_by_parent_id
    
    @active_tab = "Skyline::Page"
    @page = Skyline::Page.find_by_id(params[:referable_id]) if params[:referable_id].present?
    
    render :partial => "index"
  end
end