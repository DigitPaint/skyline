class Skyline::Media::DirsController < Skyline::ApplicationController
  
  layout "skyline/layouts/media"
  # menu :main, :media

  self.default_menu_item = :media_library
  
  def index
    @dirs = Skyline::MediaDir.group_by_parent_id
    @dir = Skyline::MediaDir.root
  end
  
  def show
    @dir = Skyline::MediaDir.find(params[:id])
    
    # selected_file = params[:selected_file_id].nil? || params[:selected_file_id] == "0" ? nil : Skyline::MediaFile.find(params[:selected_file_id])
    
    render :update do |p|
      p.replace_html("contentPanel", :partial => "show")
      p.replace_html("metaPanel", :partial => "edit")      
    end    
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
    render :update do |p|
      p.replace "dirtree", :partial => "index"
      p.replace_html("contentPanel", :partial => "show")
      p.replace_html("metaPanel", :partial => "edit")      
    end
  end
  
  def update    
    @dir = Skyline::MediaDir.find(params[:id])
    
    if params[:skyline_media_dir]
      @dir.name = params[:skyline_media_dir][:name] if !params[:skyline_media_dir][:name].blank?
      @dir.parent_id = (params[:skyline_media_dir][:parent_id] == "0") ? nil : params[:skyline_media_dir][:parent_id]
    
      @saved = @dir.save
    end
    
    @dirs = Skyline::MediaDir.group_by_parent_id 
    render :update do |p|
      if @saved
        p.notification :success, t(:success, :scope => [:media, :dirs,:update,:flashes])
      else
        p.notification :failed, t(:success, :scope => [:media, :dirs,:update,:flashes])
      end
      p.replace "dirtree", :partial => "index"
      p.replace_html("contentPanel", :partial => "show")
      p.replace_html("metaPanel", :partial => "edit")      
    end
  end  
  
  def destroy
    destroy_dir = Skyline::MediaDir.find(params[:id])
    
    @dir = destroy_dir.directory
    destroy_dir.destroy

    @dirs = Skyline::MediaDir.group_by_parent_id        
    render :update do |p|
      p.notification :success, t(:success, :scope => [:media, :dirs,:destroy,:flashes])
      p.replace "dirtree", :partial => "index"
      p.replace_html("contentPanel", :partial => "show")
      p.replace_html("metaPanel", :partial => "edit")      
    end
  end
  
end