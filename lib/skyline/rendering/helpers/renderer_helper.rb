module Skyline::Rendering::Helpers::RendererHelper

  def assign(key, value = nil)
    return @_template_assigns[key] if value.nil?
    @_template_assigns[key] = value
  end

  def renderer
    @_renderer
  end
  
  def render_object(object, options = {})
    renderer.render(object, options)
  end
  
  def render_collection(objects, options = {},&block)
    renderer.render_collection(objects, options, &block)
  end
  
  def peek(n=1, &block)
    renderer.peek(n, &block)
  end
  
  def peek_until(&block)
    renderer.peek_until(&block)
  end
  
  def render_until(&block)
    renderer.render_until(&block)
  end    
  
  def skip!(n=1)
    renderer.skip!(n)
  end

  def skip_until!(&block)
    renderer.skip_until!(&block)
  end
          
  def session
    @_controller.session
  end
  
  def params
    @_controller.params
  end
  
  def cookies
    @_controller.cookies
  end
  
  def request
    @_controller.request
  end
  
  def flash
    @_controller.send(:flash)
  end
  
  def site
    @_site
  end
  
  def url_for(options = {})
    options ||= {}
    url = case options
    when String
      super
    when Hash
      options = { :only_path => options[:host].nil? }.update(options.symbolize_keys)
      escape  = options.key?(:escape) ? options.delete(:escape) : true
      @_controller.send(:url_for, options)
    when :back
      escape = false
      @_controller.request.env["HTTP_REFERER"] || 'javascript:history.back()'
    else
      super
    end

    escape ? escape_once(url) : url
  end
  
  def protect_against_forgery?
    @_controller.send(:protect_against_forgery?)
  end
  
  def request_forgery_protection_token
    @_controller.request_forgery_protection_token
  end
  
  def form_authenticity_token
    @_controller.send(:form_authenticity_token)
  end
  
  # Simple, quick 'n dirty solution so you can use 'acticle_version', 'news_item', .. in all 
  # your templates. So you don't have to use @.... or pass the local to all partials.
  def method_missing(method, *params, &block)
    return @_local_object if @_local_object_name == method
    super
  end
end