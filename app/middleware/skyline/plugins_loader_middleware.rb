class Skyline::PluginsLoaderMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Load external skyline plugins
    Dir[Rails.root + "vendor/skyline_plugins/*/skyline/load.rb"].each do |file|
      load file
    end
    
    @app.call(env)
  end
end
