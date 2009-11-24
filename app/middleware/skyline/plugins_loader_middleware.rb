class Skyline::PluginsLoaderMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    Skyline::PluginsManager.load_all!    
    @app.call(env)
  end
end
