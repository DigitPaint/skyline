module Skyline::PagesHelper  
  
  # Renders a label and selectbox for the sectionable_type passed in, it doesn't render
  # anything if there is only one template.
  #
  # ==== Parameters
  # st<String,Symbol> :: The sectionable type
  # form<FormBuidler> :: The formbuilder to place this select in.
  # options<Hash>     :: See options
  #
  # ==== Options
  # :label<String,false> :: Use another label or false for no label
  #
  # ==== Returns
  # String :: The label and the selectbox
  # nil :: Nil if there is nothing to render
  # --
  def renderable_templates_select(object, form, options = {})
    raise "@renderable_scope not available" unless @renderable_scope
    
    return nil if @renderable_scope.templates_for(object).size <= 1
    
    options.reverse_merge! :label => Skyline::Section.human_attribute_name("template")
    
    out = []
    if options[:label]
      out << form.label(:template, options[:label]) 
      out << ": "
    end
    out << form.select(:template, templates_for_select(object) )
    out.join.html_safe
  end
  
  def templates_for_select(object)
    raise "@renderable_scope not available" unless @renderable_scope
    
    scope = [:templates]
    scope += object.class.name.sub(/^Skyline::/,"").underscore.split("/").map(&:to_sym)
    templates = @renderable_scope.templates_for(object).dup
    templates = (["default"] + templates) if templates.delete("default")
    templates.map {|tmpl| [t(tmpl,:scope => scope, :default => tmpl),tmpl]  }
  end
  
end