module Skyline::ApplicationHelper
  
  # The skyline URL/PATH prefix for the mountable location
  #
  # @return [String] the prefix used to mount Skyline
  def skyline_path_prefix
    Skyline::Engine.routes._generate_prefix({})
  end
  
  
  # Place a tick or a cross depending on the value of bool
  #
  # @param [Boolean] bool The value of the tick/cross
  # @param [Hash] options ({}) Options will be passed to the image_tag method
  def tick_image(bool,options={})
    name = bool ? "true" : "false"
    src = "/skyline/images/icons/#{name}.gif"
    
    options.reverse_merge! :alt => t(name, :scope => [:icons]) 
    
    image_tag(src,options)
  end
  
  # Set the Skyline JS layout to use. Used in templates so the layout can initialize the correct layout.
  #
  # @param [Symbol] name The name of the js layout to use @see #render_js_layout
  def use_js_layout(name)
    @_js_layout = name
  end
  
  # Does this template have  a Skyline JS Layout set?
  #
  # @return [Boolean]
  def has_js_layout?
    @_js_layout.present?
  end  
  
  # Actually render the JS code to initialize the previously set Skyline JS Layout.
  # 
  # @todo Currently only implemented in EntopicEditor plugin
  def render_js_layout
    return unless @_js_layout
    raise "TO BE IMPLEMENTED"
  end  
  
  # You can use this method to place a message directly in your view. This also
  # works directly from a render(:update) or an update_page block. 
  # 
  # @param [Symbol] type The type of the message (:error,:notification,:success)
  # @param [String] message The message to show
  # @param [Hash] options ({}) Options to be passed to the MessageGenerator (javascript)
  def message(type,message,options={})
    Skyline::MessageGenerator.new(type,message,options)
  end

  # You can use this method to place a notification directly in your view. This also
  # works directly from a render(:update) or an update_page block. 
  # 
  # @param [Symbol] type The type of the message (:error,:notification,:success)
  # @param [String] message The message to show
  # @param [Hash] options ({}) Options to be passed to the MessageGenerator (javascript)
  def notification(type,message,options={})
    Skyline::NotificationGenerator.new(type,message,options)    
  end
  
  # Actually render the messages on screen.
  # 
  # @option options [Class] :generator (Skyline::MessageGenerator) The generator to use to render the messages.
  def render_messages(options={})
    javascript_tag render_messages_javascript(options)
  end
  
  # Actually render the notifications on screen.
  #
  # @option options [Class] :generator (Skyline::NotificationGenerator) The generator to use to render the messages.
  def render_notifications(options={})
    javascript_tag render_notifications_javascript(options)
  end

  def render_messages_javascript(options={})
    _render_volatiles(self.messages,options)    
  end
  
  def render_notifications_javascript(options={})
    options.reverse_merge! :generator => Skyline::NotificationGenerator
    _render_volatiles(self.notifications,options)
  end
  
  protected
  
  def _render_volatiles(messages_hash, options={})
    return "" unless messages_hash.any?
    options.reverse_merge! :generator => Skyline::MessageGenerator
    generator = options.delete(:generator)
    out = messages_hash.inject([]) do |acc,v|
      type, messages = v[0],[v[1]].flatten
            
      msg_options = messages.extract_options!      
      msg_options.reverse_merge! options
            
      acc += messages.map{|msg| generator.new(type,msg,msg_options) }
    end
    out.join("\n").html_safe
  end
  
end