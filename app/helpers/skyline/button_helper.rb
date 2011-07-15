module Skyline::ButtonHelper
  
  def menu_button(title, options={}, &block)
    options.reverse_merge! :id => Guid.new
    
    contents = capture(&block)
    
    txt = <<-EOS
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
    
    txt.html_safe
  end
  
  # Translates the key if it's a symbol otherwise just places key
  # --
  def button_text(key)
    (key.kind_of?(Symbol) ? t(key, :scope => :buttons) : key).html_safe
  end
  
  # Places a <button type="submit">..</button> tag
  #
  # ==== Parameters
  # src :: The location of the image relative to the locale directory
  # options :: Options to pass through to content_tag
  #
  # ==== Options
  # :value :: If value is a symbol, it will be translated in scope buttons
  # --
  def submit_button(label,options={})
    convert_boolean_attributes!(options, %w( disabled ))
    
    options.reverse_merge! :type => "submit"
    content_tag("button", button_text(label) ,options)
  end
  
  def submit_button_to(label,options={},html_options={})
    
    html_options = html_options.stringify_keys
    disabled = html_options[:disabled]
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
    
    html_options.reverse_merge! :type => "submit"
    
    ("<form method=\"#{form_method}\" action=\"#{escape_once url}\" class=\"button-to\"><div>" +
      method_tag + content_tag("button", button_text(label) ,html_options) + request_token_tag + "</div></form>").html_safe    
  end
  
end