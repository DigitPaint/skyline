# The parameter needs to be a proc because we want it to evaluate on instantiation.
ActionController::Dispatcher.middleware.use Skyline::FlashSessionCookieMiddleware, Proc.new{ ActionController::Base.session_options[:session_key] || ActionController::Base.session_options[:key] }

# Only needed for development, the files will be cached in Production.
# --
ActionController::Dispatcher.middleware.use(Skyline::SprocketsMiddleware, Rails.public_path, "skyline/javascripts/src", :cache => (Rails.env == "production") ) do |env|
  env.register_load_location("skyline/src")
  env.register_load_location("skyline/vendor/*")
  env.register_load_location("skyline.editor/src")  
  env.register_load_location("skyline.editor/vendor/*")
  env.register_load_location("skyline.editor/vendor/tinymce/jscripts/*")  
  
  env.map "skyline/javascripts/application.js", "skyline/javascripts/src/application.js"
  env.map "skyline/javascripts/skyline.js", "skyline/javascripts/src/skyline.js"  
  env.map "skyline/javascripts/skyline.editor.js", "skyline/javascripts/src/skyline.editor.js"    
end

ActionController::Dispatcher.middleware.use Skyline::PluginsLoaderMiddleware
