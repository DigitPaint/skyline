# The {Skyline::PluginsManager} load all plugins. Currently the manager is quite
# static as it can only load plugins from `Rails.root/vendor/skyline_plugins`. As
# we extend the Plugin API the manager will become more advanced.
# 
# @private
class Skyline::PluginsManager
  class << self
    def init_all!
      public_skyline_plugins_path = Pathname.new(Rails.public_path) + "skyline_plugins"
      FileUtils.mkdir(public_skyline_plugins_path) unless public_skyline_plugins_path.exist?
            
      # Initialize external skyline plugins (only once)
      Dir[Rails.root + "vendor/skyline_plugins/*/skyline/init.rb"].each do |file|
        load file
      end
    end
        
    def load_all!
      # Load external skyline plugins (possibly at every request)
      Dir[Rails.root + "vendor/skyline_plugins/*/skyline/load.rb"].each do |file|
        load file
      end      
    end
    
    def migration_paths
      Dir[Rails.root + "vendor/skyline_plugins/*/db/migrate"]
    end
  end
end
