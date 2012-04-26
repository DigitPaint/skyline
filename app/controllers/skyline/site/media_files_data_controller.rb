class Skyline::Site::MediaFilesDataController < ApplicationController  
  after_filter :perform_cache, :only => :show
  
  self.page_cache_directory = Skyline::MediaCache.cache_path
  
  # Regex to check the size parameter
  SIZE_REGEX = /\A\d+(x\d+)?\Z/  
  
  # show
  # Renders the requested image with specified size parameters and stores the image in the cache. 
  # If the image is already in the cache then 304 Not Modified is rendered.
  #
  # ==== Parameters
  # size <String> WidthxHeight
  
  def show
    @skip_caching = false

    filename = "#{params[:name]}.#{params[:format]}"
    
    @media_file = Skyline::MediaFile.first(:conditions => {:parent_id => params[:media_dir_id], :name => filename})
    return self.handle_404 unless @media_file
          
    # Chceck if we have a :cache_key
    if params[:cache_key].present?
      response.headers["Expires"] = CGI.rfc1123_date(Time.now + 10.years)
      response.headers["Cache-Control"] = "max-age=#{10.years.to_i}, public"
      
      if params[:cache_key].to_s != @media_file.cache_key
        # redirect to correct :cache_key
        sz = params[:size] && params[:size] =~ SIZE_REGEX ? params[:size] : nil
        return redirect_to @media_file.url(sz, :cache => true), :status => :moved_permanently
      end
    end    
    
    cached_file = File.join(self.page_cache_directory.to_s, CGI::unescape(request.path))

    if File.exist?(cached_file)                      
      response.etag = File.mtime(cached_file)
          
      if request.etag_matches?(response.etag)
        head :not_modified
      else
        send_file cached_file, :filename => @media_file.name ,:type => @media_file.content_type, :disposition => 'inline', :stream => false, :cache => true
      end
      @skip_caching = true
    else
      
      # Size normalization.
      size = normalize_size
      
      if size.nil?
        response.etag = File.mtime(@media_file.file_path)
            
        if request.etag_matches?(response.etag)
          head :not_modified
        else
          send_file @media_file.file_path, :filename => @media_file.name, :type => @media_file.content_type, :disposition => 'inline', :cache => true
        end
        @skip_caching = true
      elsif size === false
        return render :nothing => true, :status => :unprocessable_entity
      else
        send_data @media_file.thumbnail(size[0],size[1]), :filename => @media_file.name, :type => @media_file.content_type, :disposition => 'inline', :cache => true
      end
    end
    
  end
  
  protected
  
  # Normalizes the size parameter
  #
  # @return [nil,false,Array[width,height]] Nil if no sizing should be done, false if this is just wrong and an array with [w,h] if it's ok.
  def normalize_size
    if params[:size].present?
      if params[:size] =~ SIZE_REGEX
        size = params[:size].to_s.split("x").map{|v| v.to_i }
    
        # Unless all the sizes are set we have to assume this is crap and return an :unprocessable_entity 
        if !size.all?{|s| s > 0 }
          return false
        end    
    
        # Never upscale images disproportionally
        if size[0] == @media_file.width && size[1] >= @media_file.height || size[1] == @media_file.height && size[0] >= @media_file.width
          return nil
        end
      else
        return false
      end
    else
      return nil
    end
    size
  end
  
  def handle_404
    render :nothing => true, :status => :not_found    
  end
    
  def perform_cache
    return if @skip_caching
    return unless @media_file
    ActiveRecord::Base.transaction do
      Skyline::MediaCache.create(:url => request.path, :object_type => "MediaFile", :object_id => @media_file.id)
      self.class.cache_page(response.body, request.path)
    end
  end
end