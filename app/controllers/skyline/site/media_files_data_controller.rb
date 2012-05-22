class Skyline::Site::MediaFilesDataController < ApplicationController  
    
  # show
  # Renders the requested image with specified size parameters and stores the image in the cache. 
  #
  # ==== Parameters
  # size <String> WidthxHeight    
  def show
    @skip_caching = false
    
    # Handle old URL'S
    return handle_old_style_url! if params[:dir_id].present?
    
    @file = Skyline::MediaFile.first(:conditions => {:id => params[:file_id], :name => params[:name]})
    return self.handle_404 unless @file
          
    # Chceck if we have a cache_key
    if params[:cache_key].present?
      response.headers["Expires"] = CGI.rfc1123_date(Time.now + 10.years)
      response.headers["Cache-Control"] = "max-age=#{10.years.to_i}, public"
      
      # Handle stale cache keys
      return handle_incorrect_url! if params[:cache_key].to_s != @file.cache_key
    end    
    
    cached_file_path = File.join(self.cache_base_path, self.cache_file_path)
    
    if !File.exist?(cached_file_path)
      # Size normalization.
      size = @file.normalize_size(params[:size])
      
      if size === false
        # File has invalid sizes
        return render :nothing => true, :status => :unprocessable_entity
      elsif size.nil?
        cache_file(self.cache_file_path, @file, File.open(@file.file_path, "rb"))
      elsif !@file.allowed_size?(size[0],size[1])
        return render :nothing => true, :status => :not_found
      else
        # Send the resized data
        cache_file(self.cache_file_path, @file, @file.thumbnail(size[0],size[1]))
      end
    end

    send_file cached_file_path, :filename => @file.name ,:type => @file.content_type, :disposition => 'inline'    
  end
  
  protected
  
  # @param file_path [String] The path of the file, will be sanitized (this path is without the #cache_base_path)
  # @param object [Object] The object we attach the MediaCache to
  # @param data [String, #each] A string or IO object with data to be cached.
  def cache_file(file_path, object, data)
    ActiveRecord::Base.transaction do
      Skyline::MediaCache.create(:url => file_path, :object_type => object.class.to_s, :object_id => object.id)      
      
      path = File.join(self.cache_base_path, file_path)
      
      FileUtils.makedirs(File.dirname(path))
      if !data.respond_to?(:to_str) && data.respond_to?(:each)
        File.open(path, "wb+"){|f| data.each{|d| f.write(d) } }
        data.close if data.respond_to?(:close)
      else
        File.open(path, "wb+"){|f| f.write(data) }
      end
    end
  end
  
  def cache_base_path
    Skyline::MediaCache.cache_path    
  end
  
  def cache_file_path
    URI.parser.unescape(request.path.chomp('/'))
  end
  
  # Old style URL's are maintained for migration purposes.
  def handle_old_style_url!
    @file = Skyline::MediaFile.first(:conditions => {:parent_id => params[:dir_id], :name => params[:name]})
    return self.handle_404 unless @file
    handle_incorrect_url!
  end  
  
  def handle_incorrect_url!
    response.headers["Expires"] = CGI.rfc1123_date(Time.now + 10.years)
    response.headers["Cache-Control"] = "max-age=#{10.years.to_i}, public"
    
    if @file.valid_size?(params[:size]) || params[:size].blank?
      redirect_to @file.url(params[:size], :mode => :published), :status => :moved_permanently
    else
      self.handle_404
    end    
  end
  
  def handle_404
    render :nothing => true, :status => :not_found    
  end    
end