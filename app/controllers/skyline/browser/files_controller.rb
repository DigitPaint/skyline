class Skyline::Browser::FilesController < Skyline::ApplicationController
  def index
    @media_dirs = Skyline::MediaDir.group_by_parent_id
    
    if params[:referable_type].present? && params[:referable_id].present?
      case params[:referable_type]
        when "Skyline::MediaFile" then
          @media_file = Skyline::MediaFile.find_by_id(params[:referable_id])
          @media_dir = @media_file.directory if @media_file
          @active_tab = "Skyline::MediaFile"
      end
    end
    
    @active_tab ||= "Skyline::MediaFile"
    
    render :partial => "index"
  end
end
