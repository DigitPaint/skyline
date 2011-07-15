# @private
class Skyline::MessageGenerator
  include ActionView::Helpers::JavaScriptHelper
  
  def initialize(type,message,options={})
    (@options = options || {}).update(:type => "'#{escape_javascript(type.to_s)}'")
    @message = message
  end
  
  def to_s
    options = @options.dup
    options.each do |k,v|
      options[k] = case v
        when Hash : v.to_json
        else v
      end
    end    
    "new #{self.js_object}('#{self.escape_javascript(@message)}',#{self.to_json(options)})"
  end
  
  def to_str
    to_s
  end
  
  def js_object
    "Application.Message"
  end
  
end