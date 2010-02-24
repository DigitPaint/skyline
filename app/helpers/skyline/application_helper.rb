module Skyline::ApplicationHelper  
  # Place a tick or a cross depending on the value of bool
  #
  # ==== Parameters
  # bool<Boolean>:: The value of the tick/cross
  # options<Hash>:: Options will be passed to the image_tag method
  # 
  # --
  def tick_image(bool,options={})
    name = bool ? "true" : "false"
    src = "/skyline/images/icons/#{name}.gif"
    
    options.reverse_merge! :alt => t(name, :scope => [:icons]) 
    
    image_tag(src,options)
  end
  
  # You can use this method to place a message directly in your view. This also
  # works directly from a render(:update) or an update_page block. 
  # 
  # ==== Parameters
  # type<Symbol>:: The type of the message (:error,:notification,:success)
  # message<String>:: The message to show
  # optiosn<Hash>:: Options to be passed to the MessageGenerator (javascript)
  #
  # --
  def message(type,message,options={})
    Skyline::MessageGenerator.new(type,message,options)
  end

  # You can use this method to place a notification directly in your view. This also
  # works directly from a render(:update) or an update_page block. 
  # 
  # ==== Parameters
  # type<Symbol>:: The type of the message (:error,:notification,:success)
  # message<String>:: The message to show
  # optiosn<Hash>:: Options to be passed to the MessageGenerator (javascript)
  #
  # --  
  def notification(type,message,options={})
    Skyline::NotificationGenerator.new(type,message,options)    
  end
  
  def render_messages(options={})
    _render_volatiles(self.messages,options)
  end
  
  def render_notifications(options={})
    options.reverse_merge! :generator => Skyline::NotificationGenerator
    _render_volatiles(self.notifications,options)
  end
  
  def plugin_hook(name)
    template = caller.first[/app\/views\/([^:]*):/,1]
    raise "Cannot determine template from caller: #{caller}" unless template
    plugin_template = template.sub(".html.erb", "_#{name}.html.erb")
    
    logger.debug "Looking for template #{plugin_template} in plugins..."
    Dir[Rails.root + "vendor/skyline_plugins/*/app/views/#{plugin_template}"].each do |file|      
      if RAILS_ENV == "development"
        concat render(:inline => File.read(file), :layout => nil)
      else
        # render :file caches the file somehow, so only use it in production mode
        concat render(:file => file, :layout => nil)
      end
    end    
  end
  
  protected
  
  def _render_volatiles(messages_hash, options={})
    return "" unless messages_hash.any?
    options.reverse_merge! :generator => Skyline::MessageGenerator
    generator = options.delete(:generator)
    out = messages_hash.inject([]) do |acc,v|
      type,messages = v[0],[v[1]].flatten
      msg_options = messages.extract_options!
      msg_options.reverse_merge! options
      acc += messages.map{|msg| generator.new(type,msg,msg_options) }
    end
    javascript_tag out.join("\n")    
  end
end