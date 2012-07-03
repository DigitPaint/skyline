# Extend the Rails route mapper to add the #mount_skyline method

mappers = [ActionDispatch::Routing::Mapper]
mappers << ActionDispatch::Routing::DeprecatedMapper if defined?(ActionDispatch::Routing::DeprecatedMapper)
mappers.each do |mapper|
  mapper.class_eval do
    
    def mount_skyline(options = {}, &block)
      options.reverse_merge! :skyline_path => "/skyline", :media_path => "/media"
      
      Skyline::Engine.config.skyline.mounted_engine_path = options[:skyline_path]
      Skyline::Engine.config.skyline.mounted_media_path = options[:media_path]

      # Create symlinks for media and assets
      create_symlink(Skyline.root + "public/skyline", options[:skyline_path])
      
      if Rails.env.production?
        media_path = Pathname.new(options[:media_path])
        media_path = media_path.relative_path_from(Pathname.new('/')) if media_path.absolute?
        create_symlink(Pathname.new(Skyline::MediaCache.cache_path) + media_path, media_path)
      end
      
      mount Skyline::Engine => options[:skyline_path], :as => "skyline"
      
      # Allow implementation to add routes to Skyline
      # Do not add these routes during test as they will cause routing errors in media browser tests
      if block_given? && !Rails.env.test?
        Skyline::Engine.routes.draw do
          instance_exec(&block)
        end
      end
      
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
        match "#{options[:media_path]}/dirs/:dir_id/data/:name", :to => "skyline/site/media_files_data#show", :via => :get, :name => /[^\/]+/
        match "#{options[:media_path]}/dirs/:dir_id/data/:size/:name", :to => "skyline/site/media_files_data#show", :via => :get, :name => /[^\/]+/        
    end
  end
end

def create_symlink(origin, destination)
  origin_path = Pathname.new(origin)
  destination_path = Pathname.new(destination)
  destination_path = destination_path.relative_path_from(Pathname.new('/')) if destination_path.absolute?

  full_path = Pathname.new(Rails.public_path) + destination_path

  unless full_path.exist?
    FileUtils.rm(full_path) if full_path.symlink?

    puts "=> Skyline: Creating symlink to '#{full_path}' from #{origin_path}"
    FileUtils.ln_s(origin_path.relative_path_from(Pathname.new(Rails.public_path)),full_path)
  end
end