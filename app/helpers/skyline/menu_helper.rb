module Skyline::MenuHelper
  
  # @param scope [Array]
  # @param url [String,Hash]
  # @param options [Hash]
  def menu_item(*scope)
    scope = Array(scope)
    url_options = scope.extract_options!
    options = url_options.slice!(:method)
        
    url = scope.pop
    scope = current_menu_scope(scope)
    if controller.current_menu[0, scope.size] == scope
      (options[:class] ||= "") << " active"
    end
    
    
    content_tag("li", link_to(t(scope.last, :scope => [:navigation, scope[-2]]), url, url_options), options)
  end

  def current_menu_scope(scope)
    (@_menu_scope || []) + scope
  end
    
end