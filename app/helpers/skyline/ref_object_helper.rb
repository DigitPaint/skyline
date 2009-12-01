module Skyline::RefObjectHelper
  # Get the title of a ref_object.
  def ref_object_title(referable,default = "")
    return referable.default_variant_data.andand.navigation_title.to_s if referable.class.to_s == "Skyline::Page"
    return referable.name.to_s if referable.class.to_s == "Skyline::MediaFile"
    return referable.title.to_s if referable.respond_to?(:title)
    default
  end
  
  def ref_object_css_class(referable)
    case referable.andand.class.to_s
    when "Skyline::Page"
      "page"
    when "Skyline::MediaFile"
      "mediaFile #{referable.file_type}"
    else
      "external"
    end    
  end  
  

  # options[:object]      defaults to: form_builder.object.send(field) || form_builder.object.send("build_#{field}")
  # options[:container]   defaults to: form_builder.dom_id(field)
  def image_browser(form_builder, field, options = {})
    referable_field_browser(form_builder, field, :image, options)
  end
  
  def link_browser(form_builder, field, options = {})
    referable_field_browser(form_builder, field, :link, options)
  end
  
  def referable_field_browser(form_builder, field, browser, options = {})
    options.reverse_merge! :object => form_builder.object.send(field) || form_builder.object.send("build_#{field}"), 
                           :container => form_builder.dom_id(field),
                           :skip_class => false

    c = []
      
    form_builder.fields_for "#{field}_attributes", options[:object] do |linked_form|
      c << linked_form.hidden_field(:id) unless linked_form.object.new_record?    
      c << linked_form.hidden_field(:referable_type, :class => "referable_type")
      c << linked_form.hidden_field(:referable_id, :class => "referable_id")
      c << linked_form.hidden_field(:_delete, :class => "delete", :value => 0)    
      linked_form.fields_for "referable_attributes", linked_form.object.referable do |referable_form|
        c << hidden_field_tag(referable_form.object_name + "[uri]", referable_form.object.respond_to?(:uri) ? referable_form.object.uri : "", :class => "link_custom_url")
      end

      
      deselect_button = link_to_function(button_image("small/delete.gif", :alt => :delete), "Application.Browser.unlink('#{options[:container]}');", :class => "delete")
      browse_button = link_to_function(button_image("small/browse.gif", :alt => :browse), "Application.Browser.browse#{browser.to_s.camelcase}For('#{options[:container]}');")      
    
      c << content_tag("div", :class => "not-linked") do
        nl = []
        nl << t(:nothing_selected, :scope => [:browser,browser])
        nl << browse_button
      end
      
      c << content_tag("div", :class => "linked") do
        l = []
        referable_title = content_tag("span", ref_object_title(linked_form.object.andand.referable) + " ", :id => linked_form.dom_id(:title), :class => "referable_title")
        l << t(:links_to, :scope => [:browser,browser], :referable_title => referable_title)
        l << deselect_button
        l << browse_button
      end
      
      c = content_tag("div", c.join, :class => "relatesTo #{"linked" if linked_form.object.andand.referable}")
    end

    
    content_tag "div", c, :id => form_builder.dom_id(field)
  end
end
