class Skyline::Editors::PageBrowser < Skyline::Editors::Editor
  def output_without_errors
    attr_names = self.attribute_names.dup
    attr_names[-1] = attr_names[-1].to_s.gsub(/_id$/, "_attributes")
    input_name_prefix = input_name(attr_names)                    # ie: element[image_attributes]
    input_id_prefix = input_id(attr_names)                        # ie: element_image_attributes
    
    association = field.name.to_s.gsub(/_id$/, "")                # ie: image
    location = nil
    if record.respond_to?(association)
      location = :model
      page = record.send(association)
      page ||= record.send("build_#{association}")
      page_title = page.referable_type.blank? ? "" : page.andand.default_variant.andand.data.andand.navigation_title
      linked = !page.referable_type.blank?
      referable_type = page.referable_type
      referable_id = page.referable_id
    else
      location = :settings
      page = Skyline::Page.find_by_id(field.value(record))
      page_title = page.andand.default_variant.andand.data.andand.navigation_title
      linked = page.present?
      referable_type = page ? "Skyline::Page" : ""
      referable_id = page ? page.id : ""
    end
    
    <<-EOF
      <div id="#{input_id_prefix}">
        #{hidden_field_tag(input_name(attr_names+['id']), page.id) if location == :model}
        #{hidden_field_tag(input_name(attr_names+['_destroy']), 0, :class => 'delete')}
        #{hidden_field_tag(input_name(attr_names+['referable_type']), referable_type, :class => 'referable_type')}
        #{hidden_field_tag(input_name(attr_names+['referable_id']), referable_id, :class => 'referable_id')}

        <div class="content-browser">
          <div class="relatesTo#{' linked' if linked}">

            <div class="not-linked">
              <div class="blank">
                #{t(:nothing_selected, :scope => [:browser,:page])}
                #{link_to_function button_image("small/browse.gif", :alt => :browse),  "Application.Browser.browsePageFor('#{input_id_prefix}');", :class => "browse"}            
              </div>
            </div>        

            <div class="linked">
              #{t(:links_to, :scope => [:browser,:page], :referable_title => "<span class=\"referable_title\">#{page_title}</span>")}
              #{link_to_function(button_image("small/delete.gif", :alt => :delete), "Application.Browser.unlink('#{input_id_prefix}');", :class => "delete")}
              #{link_to_function button_image("small/browse.gif", :alt => :browse),  "Application.Browser.browsePageFor('#{input_id_prefix}');", :class => "browse"}
            </div>
          </div>
        </div>
      </div>
EOF
  end
end    
