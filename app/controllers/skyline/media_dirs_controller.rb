class Skyline::MediaDirsController < Skyline::ApplicationController

  layout "skyline/layouts/media"
  
  self.default_menu_item = :media_library
  
  authorize :create, :by => "media_dir_create"
  authorize :edit, :update, :by => "media_dir_update"
  authorize :destroy, :by => "media_dir_delete"
  
  def index
    @media_dirs = Skyline::MediaDir.group_by_parent_id 
  end
  
  def create
    parent_id = params[:parent_id] || 0        
    
    @parent = Skyline::MediaDir.find_by_id(parent_id)
    if @parent
      @directory = @parent.subdirectories.build()
    else
      @directory = Skyline::MediaDir.new()
    end
    @directory.save
        
    render :update do |p|
      p.replace("dirtree", 
      		:partial => "skyline/media_dirs/index", 
      		:locals => {:media_dirs => Skyline::MediaDir.group_by_parent_id, :selected_node => @directory})
    end
  end
    
  def update    
    media_dir = Skyline::MediaDir.find(params[:id])
    
    if params[:skyline_media_dir]
      media_dir.name = params[:skyline_media_dir][:name] if !params[:skyline_media_dir][:name].blank?
      media_dir.parent_id = (params[:skyline_media_dir][:parent_id] == "0") ? nil : params[:skyline_media_dir][:parent_id]
    
      media_dir.save
    end
    
    render :update do |p|
      p.replace( "dirtree", :partial => "index", :locals => {:media_dirs => Skyline::MediaDir.group_by_parent_id, :selected_node => media_dir})
    end
  end
  
  def destroy
    media_dir = Skyline::MediaDir.find(params[:id])    
    media_dir.destroy
    
    render :update do |p|
      p.replace( "dirtree", :partial => "index", :locals => {:media_dirs => Skyline::MediaDir.group_by_parent_id, :selected_node => media_dir.directory})
    end
  end
end
