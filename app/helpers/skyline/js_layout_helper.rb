module Skyline::JsLayoutHelper
  def use_js_layout(name)
    @_js_layout = name
  end
  
  def has_js_layout?
    @_js_layout.present?
  end
  
  def render_js_layout
    return unless @_js_layout
    
    t = ["Layout"]
    t << {:content => "Content", :media => "Media"}[@_js_layout.to_sym]
    
    layout_js = "new Application.#{t.compact.join(".")}()"
    javascript_tag(layout_js)
  end
end