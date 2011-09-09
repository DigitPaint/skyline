module Skyline::PluginHelper
  
  # Add a hook to the template where a plugin can place it's own template.
  # If templates from multiple plugins match the templates will be concatenated.
  def plugin_hook(name)
    template = caller.first[/app\/views\/([^:]*):/,1]
    raise "Cannot determine template from caller: #{caller}" unless template
    plugin_template = template.sub(".html.erb", "_#{name}.html.erb")
    
    logger.debug "Looking for template #{plugin_template} in plugins..."
    Dir[Rails.application.config.skyline_plugins_manager.plugin_path + "*/app/views/#{plugin_template}"].each do |file|      
      if Rails.env == "development"
        concat render(:inline => File.read(file), :layout => nil)
      else
        # render :file caches the file somehow, so only use it in production mode
        concat render(:file => file, :layout => nil)
      end
    end    
  end
  
end