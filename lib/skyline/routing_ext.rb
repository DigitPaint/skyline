# Extend the Rails route mapper to add the #mount_skyline method

mappers = [ActionDispatch::Routing::Mapper]
mappers << ActionDispatch::Routing::DeprecatedMapper if defined?(ActionDispatch::Routing::DeprecatedMapper)
mappers.each do |mapper|
  mapper.class_eval do
    
    def mount_skyline(options = {})
      options.reverse_merge! :skyline_path => "/skyline", :media_path => "/media"
      
      Skyline::Engine.config.skyline.mounted_engine_path = options[:skyline_path]
      Skyline::Engine.config.skyline.mounted_media_path = options[:media_path]
            
      mount Skyline::Engine => options[:skyline_path], :as => "skyline"
      
      match "#{options[:media_path]}/:cache_key/:file_id/:size/:name", 
        :to => "skyline/site/media_files_data#show", 
        :via => :get, 
        :name => /[^\/]+/, 
        :cache_key => /\d{2}\/\d{2}\/\d+/,
        :as  => "skyline_media_file_with_size"
        
      match "#{options[:media_path]}/:cache_key/:file_id/:name", 
        :to => "skyline/site/media_files_data#show", 
        :via => :get, 
        :name => /[^\/]+/, 
        :cache_key => /\d{2}\/\d{2}\/\d+/,
        :as => "skyline_media_file"
        
        # Old style URL's to not break old links
        match 'media/dirs/:dir_id/data/:name', :to => "skyline/site/media_files_data#show", :via => :get, :name => /[^\/]+/
        match 'media/dirs/:dir_id/data/:size/:name', :to => "skyline/site/media_files_data#show", :via => :get, :name => /[^\/]+/        
    end
  end
end
