class Skyline::Browser::LinksController < Skyline::ApplicationController
  def index
    @media_dirs = Skyline::MediaDir.group_by_parent_id
    @pages = Skyline::Page.group_by_parent_id
    
    if params[:referable_type].present?
      if params[:referable_type] == "Skyline::MediaFile"
        @media_file = Skyline::MediaFile.find_by_id(params[:referable_id])
        @media_dir = @media_file.directory if @media_file
        @active_tab = "Skyline::MediaFile"
      elsif params[:referable_type] == "Skyline::Page"
        @page = Skyline::Page.find_by_id(params[:referable_id])
        @active_tab = "Skyline::Page"
      elsif Skyline::Linkable.linkables.map(&:name).include?(params[:referable_type])
        @linkable_type = Skyline::Linkable.linkables.find{|l| l.name == params[:referable_type]}
        @linkable = @linkable_type.find_by_id(params[:referable_id])
        @active_tab = "Skyline::Linkable"
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
