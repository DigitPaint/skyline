class Skyline::Browser::MediaNodesController < Skyline::ApplicationController
  def index
    @media_dirs = Skyline::MediaDir.group_by_parent_id
    
    if params[:referable_type].present? && params[:referable_id].present?
      case params[:referable_type]
        when "Skyline::MediaDir" then
          @media_dir = Skyline::MediaDir.find_by_id(params[:referable_id])
          @active_tab = "Skyline::MediaFile"
      end
    end
    
    @active_tab ||= "Skyline::MediaFile"
    
    render :partial => "index"
  end
end
