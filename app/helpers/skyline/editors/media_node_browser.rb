class Skyline::Editors::MediaNodeBrowser < Skyline::Editors::Editor
  def output_without_errors
    attr_names = self.attribute_names.dup
    attr_names[-1] = attr_names[-1].to_s.gsub(/_id$/, "_attributes")
    input_name_prefix = input_name(attr_names)                    # ie: element[image_attributes]
    input_id_prefix = input_id(attr_names)                        # ie: element_image_attributes
    
    association = field.name.to_s.gsub(/_id$/, "")                # ie: image
    location = nil    
    if record.respond_to?(association)
      location = :model
      media_node = record.send(association)
      media_node ||= record.send("build_#{association}")
      media_node_name = media_node.referable_id.blank? ? "" : media_node.name
      linked = !media_node.referable_type.blank?
      referable_type = media_node.referable_type
      referable_id = media_node.referable_id
    else
      location = :settings
      media_node = Skyline::MediaFile.find_by_id(field.value(record))
      media_node_name = media_node.name if media_node
      linked = media_node.present?
      referable_type = media_node ? "Skyline::MediaFile" : ""
      referable_id = media_node ? media_node.id : ""
    end

    <<-EOF
      <div id="#{input_id_prefix}" class="#{!media_node.blank? && 'folder'}">
        #{hidden_field_tag(input_name(attr_names+['id']), media_node.id) if location == :model}
        #{hidden_field_tag(input_name(attr_names+['_destroy']), 0, :class => 'delete')}
        #{hidden_field_tag(input_name(attr_names+['referable_type']), referable_type, :class => 'referable_type')}
        #{hidden_field_tag(input_name(attr_names+['referable_id']), referable_id, :class => 'referable_id')}
        
        <div class="content-browser">
          <div class="relatesTo#{' linked' if linked}">
            <div class="not-linked">
              <div class="blank">
                #{t(:nothing_selected, :scope => [:browser,:file])}
                #{link_to_function button_text(:browse),  "Application.Browser.browseMediaNodeFor('#{input_id_prefix}');", :class => "browse button small"}            
              </div>
            </div>        

            <div class="linked">
              #{t(:links_to, :scope => [:browser,:file], :referable_title => "<span class=\"referable_title\">#{media_node_name}</span>")}
              #{link_to_function button_text(:delete), "Application.Browser.unlink('#{input_id_prefix}');", :class => "delete button small red"}
              #{link_to_function button_text(:browse),  "Application.Browser.browseMediaNodeFor('#{input_id_prefix}');", :class => "browse button small"}
            </div>
          </div>
        </div>
      </div>
EOF
  end
end
