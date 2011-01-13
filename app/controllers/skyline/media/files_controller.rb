class Skyline::Media::FilesController < Skyline::ApplicationController
  
  before_filter :find_dir

  self.default_menu_item = :media_library
  
  def index
    render :update do |p|
      p.replace_html "contentEditPanel", :partial => "index"
    end
  end
  
  def edit
    @file = @dir.files.find(params[:id])
    
    render :update do |p|
      p.replace_html "metaPanel", :partial => "edit"
    end
  end
  
  # We've got two different kinds of updates:
  # 1. The regular "update" through a form
  # 2. A drag action to a different directory.
  # 
  def update
    @file = @dir.files.find(params[:id])
    @file.attributes = params[:skyline_media_file]
    
    # We use an instance variable because we want to use it in the render(:update) block.
    @saved = @file.save
    
    render :update do |p|
      # file was moved to another directory
      @dir = @file.directory if @dir.id != @file.parent_id      
      
      if @saved
        p.notification :success, t(:success, :scope => [:media, :files ,:update,:flashes])
      	p.replace_html "contentPanel", :partial => "skyline/media/dirs/show"
      else
        p.message :error, t(:failed, :scope => [:media_file,:update,:flashes])
      end      
      
      p.replace_html "metaPanel", :partial => "edit"
      
    end    
  end
  
  def create
    @file = @dir.files.build(:name => params[:Filename], :data => params[:Filedata])
    
    sleep 5
    if @file.save
      render :json => {:result => "success"}
    else
      render :json => {:result => "failed"}
    end
    
  end  
  
  def destroy
    @file = @dir.files.find(params[:id])
    @file.destroy
    render :update do |p|
      p.notification :success, t(:success, :scope => [:media, :files,:destroy,:flashes])
      p.replace_html("contentPanel", :partial => "skyline/media/dirs/show")
      p.replace_html("metaPanel", :partial => "skyline/media/dirs/edit")      
    end
  end

  protected
  
  def find_dir
    @dir = Skyline::MediaDir.find(params[:dir_id])
  end
  
end
