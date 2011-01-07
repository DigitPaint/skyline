class Skyline::MediaFilesController < Skyline::ApplicationController    
  layout "skyline/layouts/media"
  # to avoid error 422 on authentication/session management
  skip_before_filter :verify_authenticity_token, :only => :create
  
  self.default_menu_item = :media_library  
      
  authorize :create, :by => "media_file_create"
  authorize :edit, :update, :by => "media_file_update"
  authorize :destroy, :by => "media_file_delete"
    
  def index    
    media_dir = Skyline::MediaDir.find(params[:media_dir_id])
    selected_file = params[:selected_file_id].nil? || params[:selected_file_id] == "0" ? nil : Skyline::MediaFile.find(params[:selected_file_id])
    
    render :update do |p|
    	if !params[:listonly]
    	  p.replace_html("contentHeaderPanel", "<span class=\"content\">#{t(:files_in, :directory => media_dir.name, :scope => [:media_file,:index])}</span>")
    		p.replace_html("uploadPanel", :partial => "new", :locals => {:media_dir => media_dir})
    		p.replace_html("metaHeaderPanel", "<span class=\"content directory\">#{media_dir.name}</span>")      
    		p.replace_html("metaBodyPanel", :partial => "skyline/media_dirs/edit", :locals => {:media_dir => media_dir})
    	end
    	    	
    	p.replace_html("filelist", :partial => "index", :locals => {:media_dir => media_dir, :show_meta_data => params[:show_meta_data], :selected_file => selected_file})
      
    end
  end
  
  def create
    @parent = Skyline::MediaDir.find_by_id(params[:media_dir_id])
    
    @media_file = Skyline::MediaFile.new(:name => params[:Filename], :parent_id => params[:media_dir_id], :data => params[:Filedata])
    @parent.files << @media_file if @parent
    
    if @media_file.save
      render :json => {:result => "success"}
    else
      render :json => {:result => "failed"}
    end
    
  end
    
  def edit
    @tags = Skyline::MediaFile.available_tags   
    media_file = Skyline::MediaFile.find(params[:id])
    
    render :update do |p|
    	p.replace_html("metaHeaderPanel", :partial => "skyline/media_files/header", :locals => {:media_file => media_file} )      
      p.replace_html("metaBodyPanel", :partial => "skyline/media_files/edit", :locals => {:media_file => media_file} )      
    end
  end
  
  def update
    @tags = Skyline::MediaFile.available_tags   
    media_file = Skyline::MediaFile.find(params[:id])
    original_media_file = media_file.clone
    media_file.attributes = params[:skyline_media_file]
    
    @saved = media_file.save
    
    render :update do |p|
      if @saved
        p.notification :success, t(:success, :scope => [:media_file,:update,:flashes])
      else
        p.message :failed, t(:failed, :scope => [:media_file,:update,:flashes])
      end
      if original_media_file.directory.id == media_file.directory.id
        # just a normal edit of the media_file
      	p.replace_html("filelist", :partial => "index", :locals => {:media_dir => media_file.directory, :selected_file => media_file})
      else
        # file was moved to another directory
      	p.replace_html("filelist", :partial => "index", :locals => {:media_dir => original_media_file.directory})
      	p.replace_html("metaHeaderPanel", "<span class=\"content folder\">#{original_media_file.directory.name}</span>")      
        p.replace_html("metaBodyPanel", :partial => "skyline/media_dirs/edit", :locals => {:media_dir => original_media_file.directory})
      end    
    end    
  end

  
  def destroy
    media_file = Skyline::MediaFile.find(params[:id])
    media_file.destroy
    
    redirect_to :action=>:index, :media_dir_id=> params[:media_dir_id]
  end
      
end
