class Skyline::PluginsLoaderMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    Rails.application.config.skyline_plugins_manager.load_all!    
    @app.call(env)
  end
end
