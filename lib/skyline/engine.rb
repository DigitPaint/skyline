require 'skyline'
require 'rails'
require 'fileutils'
require 'skyline/routing_ext'
require Skyline.root + 'config/initializers/gem_dependencies'

module Skyline
  class Engine < Rails::Engine
    isolate_namespace Skyline
    engine_name "skyline"
    self.isolated = true
    self.routes.default_scope = {}
    
    config.skyline = ActiveSupport::OrderedOptions.new
    config.skyline.mounted_engine_path = ""
    config.skyline.mounted_media_path = ""

    
    config.autoload_paths << (Skyline.root + "lib").to_s
    
    # Vendor paths
    # TODO: Check if we need to do the load_path magic we had before:
    #   application_vendor_index = $LOAD_PATH.index(Rails.root + "vendor") || 0
    #   $LOAD_PATH.insert(application_vendor_index + 1, vendor_path)
    vendor_path = (Skyline.root + "vendor").to_s    
    config.autoload_paths << vendor_path
    config.autoload_once_paths << vendor_path
        
    initializer "skyline.setup_public_paths" do |app|
      puts "Setup public paths"
      Rails.application.reload_routes!
      
      skyline_path = Pathname.new(Skyline::Engine.config.skyline.mounted_engine_path || "skyline")
      skyline_path = skyline_path.relative_path_from(Pathname.new('/')) if skyline_path.absolute?
      
      public_path = Pathname.new(Rails.public_path) + skyline_path
      
      unless public_path.exist? 
        FileUtils.rm(public_path) if public_path.symlink?
        
        puts "=> Skyline: Creating assets symlink to '#{public_path}'"
        FileUtils.ln_s((Skyline.root + "public/skyline").relative_path_from(Pathname.new(Rails.public_path)),public_path)
      end      
    end
       
   #  Middleware
   
    initializer "skyline.setup_session" do |app|
      Skyline::Engine::SESSION_KEY = app.config.session_options[:key].to_s + "_skyline"
      Skyline::Engine::SESSION_OPTIONS = app.config.session_options.dup
      Skyline::Engine::SESSION_OPTIONS[:key] = Skyline::Engine::SESSION_KEY
     
      middleware.use Skyline::SessionScrubberMiddleware
      middleware.use ActionDispatch::Session::CookieStore, Skyline::Engine::SESSION_OPTIONS
      # middleware.use Proc.new{|env| puts env["rack.session"] }
    end
   
    initializer "skyline.setup_middleware" do
      # Only needed for development, the files will be cached in Production.
      middleware.use(Skyline::SprocketsMiddleware, Rails.public_path, "skyline/javascripts/src", :cache => (Rails.env == "production") ) do |env|
        env.register_load_location("")
        env.register_load_location("skyline/src")
        env.register_load_location("skyline/vendor/*")
        env.register_load_location("skyline/vendor/plupload/js")
        env.register_load_location("skyline/vendor/mootools/")
     
        env.register_load_location("skyline.editor/src")
        env.register_load_location("skyline.editor/vendor/*")
        env.register_load_location("skyline.editor/vendor/tinymce/jscripts/*")
     
        env.map "skyline/javascripts/application.js", "skyline/javascripts/src/application.js"
        env.map "skyline/javascripts/skyline.js", "skyline/javascripts/src/skyline.js"
        env.map "skyline/javascripts/skyline.editor.js", "skyline/javascripts/src/skyline.editor.js"
      end
      
      if !Rails.configuration.cache_classes && Rails.configuration.reload_plugins
        middleware.use(Skyline::PluginsLoaderMiddleware)
      end
      
      middleware.use OmniAuth::Builder do
        provider Skyline::Authentication::SkylineStrategy, :callback_path => "/auth/skyline_strategy/callback"
      end
    end
    
    initializer "skyline.setup_plugins_manager" do |app|
      app.config.skyline_plugins_manager = Skyline::Plugins::Manager.new(self, app)
      if app.config.cache_classes || !app.config.reload_plugins
        app.config.skyline_plugins_manager.load_all!
      end      
    end
    
  end
end