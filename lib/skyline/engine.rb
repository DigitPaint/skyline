require 'rails'
require 'fileutils'

module Skyline
  class Engine < Rails::Engine
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
      public_path = Pathname.new(Rails.public_path) + "skyline"
      unless public_path.exist? 
        FileUtils.rm(public_path) if public_path.symlink?

        puts "=> Skyline: Creating assets symlink to '#{public_path}'"
        FileUtils.ln_s((Skyline.root + "public/skyline").relative_path_from(Pathname.new(Rails.public_path)),public_path)
      end      
    end
    
    initializer "skyline.setup_plugins_manager" do |app|
      Skyline::PluginsManager.init_all!
      if app.config.cache_classes || !app.config.reload_plugins
        Skyline::PluginsManager.load_all!
      end      
    end
    
  end
end