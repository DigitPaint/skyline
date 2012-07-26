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
# The pluginmanager will also load: `PLUGIN/skyline/plugin.rb` on intialization (after it sets up the above paths)
# And the pluginmanager will run `PLUGIN/skyline/load.rb` on every request (in development mode)
# 
#
# A plugin MUST subclass Skyline::Plugins::Plugin to register itself. Example content of plugin.rb:
#
#  module SkylineForms
#    class Plugin < Skyline::Plugins::Plugin
#    end
#  end
#
# @private
class Skyline::Plugins::Manager
  
  attr_reader :app, :engine, :plugins
  
  def initialize(engine, app)
    @app = app
    @engine = engine
  end
    
  # Initialize all plugins
  def init_all!
    FileUtils.mkdir(self.public_path) unless self.public_path.exist?

    @plugins ||= []
    Dir[self.plugin_path + "*"].each do |path|
      if self.valid_plugin?(path) && !@plugins.detect{|p| p.path == path}
        before_size = self.plugins.size
        load(path + "/skyline/plugin.rb")
        if self.plugins.size > before_size
          loaded_plugin = self.plugins.last
          loaded_plugin.path = path  
          loaded_plugin.init!
        end
      end
    end
  end

  # Load all plugins
  def load_all!
    self.plugins.each(&:load!)
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
    Pathname.new(self.app.paths['public'].to_a.first) + "skyline_plugins"
  end

  # Register a plugin. This is called from Skyline::Plugins::Plugin when a plugin subclasses that class.  
  def register_plugin(plugin)
    self.plugins << plugin
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