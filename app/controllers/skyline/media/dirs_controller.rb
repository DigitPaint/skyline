class Skyline::Media::DirsController < Skyline::ApplicationController
  
  layout "skyline/layouts/media"
  self.default_menu = :media_library
  
  authorize :create, :by => "media_dir_create"
  authorize :edit, :update, :by => "media_dir_update"
  authorize :destroy, :by => "media_dir_delete"
  
  def index
    @dirs = Skyline::MediaDir.group_by_parent_id
    @dir = Skyline::MediaDir.root
  end
  
  def show
    @dir = Skyline::MediaDir.find(params[:id])
    
    # selected_file = params[:selected_file_id].nil? || params[:selected_file_id] == "0" ? nil : Skyline::MediaFile.find(params[:selected_file_id])
  end
  
  def create
    parent_id = params[:parent_id] || 0        
    
    @parent = Skyline::MediaDir.find_by_id(parent_id)
    if @parent
      @dir = @parent.subdirectories.build
    else
      @dir = Skyline::MediaDir.new
    end
    @dir.save
    
    @dirs = Skyline::MediaDir.group_by_parent_id    
    render :action => "index"    
  end
  
  def update    
    @dir = Skyline::MediaDir.find(params[:id])
    
    if params[:media_dir]
      @dir.name = params[:media_dir][:name] if !params[:media_dir][:name].blank?
      @dir.parent_id = (params[:media_dir][:parent_id] == "0") ? nil : params[:media_dir][:parent_id]
    
      @saved = @dir.save
    end
    
    @dirs = Skyline::MediaDir.group_by_parent_id
    
    if @saved
      notifications.now[:success] = t(:success, :scope => [:media, :dirs,:update,:flashes])
    else
      notifications.now[:failed] = t(:failed, :scope => [:media, :dirs,:update,:flashes])
    end    
    
    render :action => "index"
  end  
  
  def destroy
    destroy_dir = Skyline::MediaDir.find(params[:id])
    
    @dir = destroy_dir.directory
    destroy_dir.destroy

    @dirs = Skyline::MediaDir.group_by_parent_id        
    notifications.now[:success] = t(:success, :scope => [:media, :dirs,:destroy,:flashes])
    
    render :action => "index"
  end
  
end