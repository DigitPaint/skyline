class Skyline::Media::DataController < Skyline::ApplicationController
  
  after_filter :perform_cache, :only => :show
  
  self.page_cache_directory = Skyline::MediaCache.cache_path
  
  # show
  # Renders the requested image with specified size parameters and stores the image in the cache. 
  # If the image is already in the cache then 304 Not Modified is rendered.
  #
  # ==== Parameters
  # size <String> WidthxHeight
  
  def show
    @skip_caching = false

    filename = "#{params[:name]}.#{params[:format]}"
    
    @file = Skyline::MediaFile.first(:conditions => {:parent_id => params[:dir_id], :name => filename})
    
    cached_file = File.join(self.page_cache_directory,request.path)    
    
    if File.exist?(cached_file)                      
      response.etag = File.mtime(cached_file)
          
      if request.etag_matches?(response.etag)
        head :not_modified
      else
        send_file cached_file, :filename => @file.name, :type => @file.content_type, :disposition => 'inline', :stream => false, :cache => true
      end
      @skip_caching = true
    else
      if params[:size].present?
        size = params[:size].to_s.split("x").map{|v| v.to_i }
        size = nil if size[0] == @file.width && size[1] >= @file.height || size[1] == @file.height && size[0] >= @file.width
      else
        size = nil
      end
      
      if size.nil?
        send_file @file.file_path, :filename => @file.name, :type => @file.content_type, :disposition => 'inline', :cache => true
        @skip_caching = true
      else
        if size.all?{|s| s > 0 }
          send_data @file.thumbnail(size[0],size[1]), :filename => @file.name, :type => @file.content_type, :disposition => 'inline', :cache => true
        else
          render :nothing => true, :status => :unprocessable_entity
        end
      end
    end        
  end
  
  protected
    def perform_cache
      return if @skip_caching
      ActiveRecord::Base.transaction do
        Skyline::MediaCache.create(:url => request.path, :object_type => "MediaFile", :object_id => @file.id)
        self.class.cache_page(response.body, request.path)
      end
    end
  
end