class Skyline::Browser::Tabs::MediaLibrary::MediaFilesController < Skyline::ApplicationController
  def index
    @media_dir = Skyline::MediaDir.find(params[:media_dir_id])
    @media_file = @media_dir.files.find_by_id(params[:media_file_id])
    
    render :update do |p|
      # if !params[:listonly]
      #   p.replace_html("browserUploadPanel", :partial => "new", :locals => {:media_dir => @media_dir})
      # end
    	    	
    	p.replace_html("browserContentPanel", :partial => "index")
    end    
  end
  
  # show
  # Renders the requested image with specified size parameters and stores the image in the cache. 
  # If the image is already in the cache then 304 Not Modified is rendered.
  #
  # ==== Parameters
  # size <String> WidthxHeight
  
  def show
    @media_file = Skyline::MediaFile.find(params[:id])
    @media_dir = @media_file.directory

    render :update do |p|
      p.replace("browserFileInfo", :partial => "show")
    end 
  end

end