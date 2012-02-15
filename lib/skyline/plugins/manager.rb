# The {Skyline::Plugins::Manager} load all plugins. Currently the manager is quite
# static as it can only load plugins from `Rails.root/vendor/skyline_plugins`. As
# we extend the Plugin API the manager will become more advanced.
# 
# The pluginmanager sets up the following for you:
# 
# * Public path (PLUGIN/public/PLUGIN_NAME)
# * Routes (PLUGIN/config/routes.rb)
# * View path (PLUGIN/app/views)
# * Load paths (PLUGIN/app/controllers, PLUGIN/app/models, PLUGIN/app/helpers)
# * Locales (PLUGIN/config/locales/*.{yml,rb})
# 
# The pluginmanager will also load: `PLUGIN/skyline/init.rb` on intialization (after it sets up the above paths)
# And the pluginmanager will run `PLUGIN/skyline/load.rb` on every request (in development mode)
# 
# @private
class Skyline::Plugins::Manager
  
  attr_reader :app, :engine
  
  def initialize(engine, app)
    @app = app
    @engine = engine
    init_all!
  end
  
    
  # Initialize all plugins
  def init_all!
    FileUtils.mkdir(self.public_path) unless self.public_path.exist?

    self.plugins.each{|path, plugin| plugin.init! }
  end

  # Load all plugins
  def load_all!
    self.plugins.each{|path, plugin| plugin.load! }  
  end
  
  # The path where all skyline plugins reside
  # 
  # @return [Pathname] Path of the plugins
  def plugin_path
    self.app.root + "vendor/skyline_plugins"
  end
  
  # The path where all public plugin assets reside
  # 
  # @return [Pathname] Rails.public_path + "skyline_plugins"
  def public_path
    Pathname.new(self.app.paths.public.to_a.first) + "skyline_plugins"
  end

  # All known plugins
  #
  # @param [Boolean] force_reload (false) Forcefully reload the plugin directories
  # 
  # @return [Array[PluginsManager]] An array of plugins
  def plugins(force_reload = false)
    return @plugins if @plugins && !force_reload
    @plugins ||= {}
    Dir[self.plugin_path + "*"].each do |path|
      @plugins[path] = Skyline::Plugins::Plugin.new(path, self) if self.valid_plugin?(path) && !@plugins.has_key?(path)
    end
    @plugins
  end
  
  # Does the path contain a valid plugin?
  #
  # @param [String] path Path of a plugin
  # 
  # @return [Boolean] 
  def valid_plugin?(path)
    p = Pathname.new(path)
    p.directory?
  end  
  
end