class Skyline::Plugins::Plugin
  
  attr_reader :manager, :name, :path, :init_file, :load_file, :migration_path, :seed_path
  
  def initialize(path, manager)
    @manager = manager
    @path = Pathname.new(path)
    @name = @path.basename.to_s
    
    files = { 
      :init_file => "skyline/init.rb",
      :load_file => "skyline/load.rb",
      :migration_path => "db/migrate",
      :seed_path => "db/fixtures" 
    }
    
    files.each do |key, path|
      
      f = @path + path
      instance_variable_set("@#{key}",f) if f.exist?
    end
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
    rp = self.path + "config/routes.rb"
    return unless rp.exist?
    self.manager.app.routes_reloader.paths.unshift(rp)
  end
  
  def add_load_paths!
    %w{app/models app/controllers app/helpers}.each do |p|
      pn = self.path + p
      $LOAD_PATH.unshift(pn) if File.directory?(pn)
      ActiveSupport::Dependencies.autoload_paths << pn.to_s if pn.exist?
    end
    $LOAD_PATH.uniq!
  end
  
  def add_view_path!
    vp = (self.path + "app/views")
    return unless vp.exist?
    engine_vp =  self.manager.engine.root + "app/views"
    
    ActiveSupport.on_load(:action_controller) do
      current_view_paths = self.view_paths
      append_view_path(vp)
      plugin_path = self.view_paths.dup.pop

      ep = self.view_paths.detect{|p| p.to_path == engine_vp.to_s}
      i = self.view_paths.paths.index(ep)
      self.view_paths = current_view_paths.paths.dup.insert(i, plugin_path)
    end

    ActiveSupport.on_load(:action_mailer) do
      prepend_view_path(vp)
    end    
  end
  
  def add_public_path!
    plugin_public_path = self.path + "public/#{self.name}"
    return unless plugin_public_path.exist?
      
    public_path = self.manager.public_path + self.name
    unless public_path.exist?
      FileUtils.rm(public_path) if public_path.symlink?
    
      puts "=> Skyline [Plugin: #{self.name}]: Creating assets symlink to '#{public_path}'"
      FileUtils.ln_s(plugin_public_path.relative_path_from(self.manager.public_path), public_path)
    end    
  end
  
  def add_locales!
    plugin_locales = Dir[self.path + "config/locales/*.{yml,rb}"]
    return unless plugin_locales.present?
    self.manager.app.config.i18n.railties_load_path.concat(plugin_locales)
  end
  
end