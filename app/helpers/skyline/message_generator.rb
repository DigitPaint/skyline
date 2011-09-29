# @private
class Skyline::MessageGenerator
  include ActionView::Helpers::JavaScriptHelper
  
  def initialize(type, message, options={})
    (@options = options || {}).update(:type => type.to_s)
    @message = message
  end
  
  def to_s
    options = @options.dup
    options.each do |k,v|
      options[k] = case v
        when Hash then v.to_json
        else v
      end
    end    
    
    js_options = [:area] 
    options_str = options.keys.map do |k|
      str = js_options.include?(k.to_sym) ? options[k] : "'#{escape_javascript(options[k])}'"
      "#{k} : #{str}"
    end.join(", ")
    
    
    
    "new #{self.js_object}('#{self.escape_javascript(@message)}',{#{options_str.html_safe}})".html_safe
  end
  
  def to_str
    to_s
  end
  
  def js_object
    "Application.Message"
  end
  
end