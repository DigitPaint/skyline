class Skyline::Browser::LinksController < Skyline::ApplicationController
  def index
    @media_dirs = Skyline::MediaDir.group_by_parent_id
    @pages = Skyline::Page.group_by_parent_id
    
    if params[:referable_type].present?
      case params[:referable_type]
        when "Skyline::MediaFile" then
          @media_file = Skyline::MediaFile.find_by_id(params[:referable_id])
          @media_dir = @media_file.directory if @media_file
          @active_tab = "Skyline::MediaFile"
        when "Skyline::Page" then
          @page = Skyline::Page.find_by_id(params[:referable_id])
          @active_tab = "Skyline::Page"          
      end
    end
    
    if @active_tab.nil? && params[:url].present?
      @active_tab = "Skyline::ReferableUri"
    else
      @active_tab ||= "Skyline::Page"
    end    
    
    render :partial => "index"
  end
end
