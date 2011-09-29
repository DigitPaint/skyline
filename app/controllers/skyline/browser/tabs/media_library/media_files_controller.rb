class Skyline::Browser::Tabs::MediaLibrary::MediaFilesController < Skyline::ApplicationController
  def index
    @media_dir = Skyline::MediaDir.find(params[:media_dir_id])
    @media_file = @media_dir.files.find_by_id(params[:media_file_id])
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
  end

end