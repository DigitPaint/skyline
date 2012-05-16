class Skyline::Media::DataController < Skyline::ApplicationController
  # show
  # Renders the requested image with specified size parameters and stores the image in the cache. 
  # If the image is already in the cache then 304 Not Modified is rendered.
  #
  # ==== Parameters
  # size <String> WidthxHeight
  
  def show
    @file = Skyline::MediaFile.first(:conditions => {:parent_id => params[:dir_id], :name => params[:name]})
    return self.handle_404 unless @file
    
    cached_file_path = File.join(self.cache_base_path,CGI::unescape(request.path))
    if File.exist?(cached_file_path)
      response.etag = File.mtime(cached_file_path)
          
      if request.etag_matches?(response.etag)
        head :not_modified
      else
        send_file cached_file_path, :filename => @file.name, :type => @file.content_type, :disposition => 'inline', :stream => false, :cache => true
      end
    else
      if params[:size].present?
        size = params[:size].to_s.split("x").map{|v| v.to_i }
        size = [0, 0] unless size.count == 2
        size = nil if size[0] == @file.width && size[1] >= @file.height || size[1] == @file.height && size[0] >= @file.width
      else
        size = nil
      end
      
      if size.nil?
        response.etag = File.mtime(@file.file_path)
            
        if request.etag_matches?(response.etag)
          head :not_modified
        else
          send_file @file.file_path, :filename => @file.name, :type => @file.content_type, :disposition => 'inline', :cache => true
        end
      else
        if size.all?{|s| s > 0 }
          file = @file.thumbnail(size[0],size[1])
          cache_file(cached_file_path, @file, file)
          send_data file, :filename => @file.name ,:type => @file.content_type, :disposition => 'inline'
        else
          render :nothing => true, :status => :unprocessable_entity
        end
      end
    end        
  end
  
  protected

  def handle_404
    render :nothing => true, :status => :not_found    
  end  
  
  def cache_file(path, object, data)
    ActiveRecord::Base.transaction do
      Skyline::MediaCache.create(:url => path, :object_type => object.class.to_s, :object_id => object.id)
      
      FileUtils.makedirs(File.dirname(path))
      File.open(path, "wb+"){|f| f.write(data) }
    end
  end
  
  def cache_base_path
    Skyline::MediaCache.cache_path
  end
  
end