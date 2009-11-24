module Skyline::ButtonHelper
  
  def menu_button(title, options={}, &block)
    options.reverse_merge! :id => Guid.new
    
    contents = capture(&block)
    
    concat <<-EOS
    <dl class="menubutton" id="#{options[:id]}">
      <dt>
        <span class="label">#{title}</span>
        <a class="toggle" href="#"><span><span>down</span></span></a>
      </dt>
      <dd>
        #{contents}
      </dd>
    </dl>
    <script type="text/javascript" charset="utf-8">
      new Skyline.MenuButton('#{options[:id]}')
    </script>
    EOS
  end
  
  # Places <img src="xxx"> tag with the right localized button image
  # --
  def button_image(src,options={})
    src,options = button_options(src,options)
    image_tag(src,options)
  end
  
  # Places a <input type=img> tag with the right image
  # localized.
  #
  # ==== Parameters
  # src :: The location of the image relative to the locale directory
  # options :: Options to pass through to image_submit_tag
  #
  # ==== Options
  # :value :: If value is a symbol, it will be translated in scope buttons
  # --
  def submit_button(src,options={})
    img_src,options = button_options(src,options)
    options.reverse_merge! :value => options[:alt]
    
    image_submit_tag img_src, options
  end
  
  
  def submit_button_to(src,options={},html_options={})
    img_src,html_options = button_options(src,html_options)    
    html_options = html_options.stringify_keys
    convert_boolean_attributes!(html_options, %w( disabled ))
    
    method_tag = ''
    if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
      method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
    end
    
    form_method = method.to_s == 'get' ? 'get' : 'post'
    
    request_token_tag = ''
    if form_method == 'post' && protect_against_forgery?
      request_token_tag = tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    end
    
    if confirm = html_options.delete("confirm")
      html_options["onclick"] = "return #{confirm_javascript_function(confirm)};"
    end
    
    url = options.is_a?(String) ? options : self.url_for(options)
    name ||= url
    
    html_options.reverse_merge! :value => options[:alt], :type => "image", :src => img_src
    
    "<form method=\"#{form_method}\" action=\"#{escape_once url}\" class=\"button-to\"><div>" +
      method_tag + tag("input", html_options) + request_token_tag + "</div></form>"
  end

  def button_options(src,options={})
    plugin = options.delete(:plugin)
    if plugin
      img_src = "/skyline_plugins/#{plugin}/images/buttons/#{locale_dir}/#{src}"
    else
      img_src = "/skyline/images/buttons/#{locale_dir}/#{src}"
    end
    
    options.reverse_merge! :alt => src.split("/").last.gsub("\..+$","").to_sym, :class => "button"
    
    if options[:alt].kind_of?(Symbol)
      options[:alt] = t(options[:alt], :scope => :buttons)
    end
    [img_src,options]
  end
  
  def locale_dir
    I18n.locale.downcase
  end
end