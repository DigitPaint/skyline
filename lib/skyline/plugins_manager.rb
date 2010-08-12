# The {Skyline::PluginsManager} load all plugins. Currently the manager is quite
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
class Skyline::PluginsManager
  class << self
    
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
      Rails.root + "vendor/skyline_plugins"
    end
    
    # The path where all public plugin assets reside
    # 
    # @return [Pathname] Rails.public_path + "skyline_plugins"
    def public_path
      Pathname.new(Rails.public_path) + "skyline_plugins"
    end
    
    
    # All paths of migrations for plugins
    #
    # @return [Array[String]] All paths that contain plugin migrations
    def migration_paths
      Dir[self.plugin_path + "*/db/migrate"]
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
        @plugins[path] = self.new(path) if self.valid_plugin?(path) && !@plugins.has_key?(path)
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
  
  attr_reader :name, :path, :init_file, :load_file
  
  def initialize(path)
    @path = Pathname.new(path)
    @name = @path.basename.to_s
    
    @init_file = @path + "skyline/init.rb"
    @init_file = nil unless @init_file.exist?
    
    @load_file = @path + "skyline/load.rb"
    @load_file = nil unless @load_file.exist?
  end
  
  
  # Initialize the plugin, this is usually done just once when the server starts
  def init!
    add_routes!
    add_load_paths!
    add_view_path!
    add_public_path!
    add_locales!

    load(@init_file) if @init_file
  end
  
  # Load the plugin, this will be done on every request in development
  # only once in production mode.
  def load!
    load(@load_file) if @load_file
  end
  
  protected
  
  def add_routes!
    rp = (self.path + "config/routes.rb")
    return unless rp.exist?
    ActionController::Routing::Routes.configuration_files = [rp.to_s] + ActionController::Routing::Routes.configuration_files
    ActionController::Routing::Routes.reload!
  end
  
  def add_load_paths!
    %w{app/models app/controllers app/helpers}.each do |p|
      pn = self.path + p
      ActiveSupport::Dependencies.load_paths << pn.to_s if pn.exist?
    end
  end
  
  def add_view_path!
    vp = (self.path + "app/views")
    ActionController::Base.view_paths << vp.to_s if vp.exist?
  end
  
  def add_public_path!
    plugin_public_path = self.path + "public/#{self.name}"
    return unless plugin_public_path.exist?
      
    public_path = self.class.public_path + self.name
    unless public_path.exist?
      FileUtils.rm(public_path) if public_path.symlink?
    
      puts "=> Skyline [Plugin: #{self.name}]: Creating assets symlink to '#{public_path}'"
      FileUtils.ln_s(plugin_public_path.relative_path_from(self.class.public_path), public_path)
    end    
  end
  
  def add_locales!
    plugin_locales = Dir[self.path + "config/locales/*.{yml,rb}"]
    return unless plugin_locales.present?
    
    idx = I18n.load_path.index(I18n.load_path.grep(/#{Rails.root}\/config\/locales.+/).first)
    I18n.load_path.insert(idx, *plugin_locales) 
  end
  
end
