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
    
    Skyline::Engine::SESSION_OPTIONS = {}
    
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
     
   #  Middleware
   
    initializer "skyline.setup_session" do |app|
      Skyline::Engine::SESSION_KEY = app.config.session_options[:key].to_s + "_skyline"
      Skyline::Engine::SESSION_OPTIONS.reverse_merge!(app.config.session_options)
      Skyline::Engine::SESSION_OPTIONS[:key] = Skyline::Engine::SESSION_KEY
      
      middleware.use Skyline::SessionScrubberMiddleware
      middleware.use Skyline::SessionStore, Skyline::Engine::SESSION_OPTIONS
    end
   
    initializer "skyline.setup_middleware" do
      middleware.use(Skyline::SprocketsMiddleware, Pathname.new(File.join(Skyline.root, "public")), "skyline/javascripts/src", :cache => (Rails.env == "production")) do |env|
        env.register_load_location("")
        env.register_load_location("skyline/src")
        env.register_load_location("skyline/vendor/*")
        env.register_load_location("skyline/vendor/plupload/js")
        env.register_load_location("skyline/vendor/mootools/")
     
        env.register_load_location("skyline.editor/src")
        env.register_load_location("skyline.editor/vendor/*")
        env.register_load_location("skyline.editor/vendor/tinymce/jscripts/*")
        
        env.map "javascripts/application.js", "skyline/javascripts/src/application.js"
        env.map "javascripts/skyline.js", "skyline/javascripts/src/skyline.js"
        env.map "javascripts/skyline.editor.js", "skyline/javascripts/src/skyline.editor.js"
      end
      
      if !Rails.configuration.cache_classes
        middleware.use(Skyline::PluginsLoaderMiddleware)
      end
      
      middleware.use OmniAuth::Builder do
        provider Skyline::Authentication::SkylineStrategy, :callback_path => "/auth/skyline_strategy/callback"
      end
    end
    
    initializer "skyline.setup_plugins_manager" do |app|
      app.config.skyline_plugins_manager = Skyline::Plugins::Manager.new(self, app)
      app.config.skyline_plugins_manager.init_all!
      if app.config.cache_classes
        app.config.skyline_plugins_manager.load_all!
      end      
    end
    
  end
end
