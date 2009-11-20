class Skyline::Editors::FileBrowser < Skyline::Editors::Editor
  def output_without_errors
    attr_names = self.attribute_names.dup
    attr_names[-1] = attr_names[-1].to_s.gsub(/_id$/, "_attributes")
    input_name_prefix = input_name(attr_names)                    # ie: element[image_attributes]
    input_id_prefix = input_id(attr_names)                        # ie: element_image_attributes
    
    association = field.name.to_s.gsub(/_id$/, "")                # ie: image
    location = nil    
    if record.respond_to?(association)
      location = :model
      media_file = record.send(association)
      media_file ||= record.send("build_#{association}")
      media_file_name = media_file.referable_id.blank? ? "" : media_file.name
      linked = !media_file.referable_type.blank?
      referable_type = media_file.referable_type
      referable_id = media_file.referable_id
    else
      location = :settings
      media_file = Skyline::MediaFile.find_by_id(field.value(record))
      media_file_name = media_file.name if media_file
      linked = media_file.present?
      referable_type = media_file ? "Skyline::MediaFile" : ""
      referable_id = media_file ? media_file.id : ""
    end
    
    <<-EOF
      <div id="#{input_id_prefix}">
        
        #{hidden_field_tag(input_name(attr_names+['id']), media_file.id) if location == :model}
        #{hidden_field_tag(input_name(attr_names+['_delete']), 0, :class => 'delete')}
        #{hidden_field_tag(input_name(attr_names+['referable_type']), referable_type, :class => 'referable_type')}
        #{hidden_field_tag(input_name(attr_names+['referable_id']), referable_id, :class => 'referable_id')}
        
        <div class="content-browser">
          <div class="relatesTo#{' linked' if linked}">
            <div class="not-linked">
              <div class="blank">
                #{t(:nothing_selected, :scope => [:content,:editors, :file_browser])}
                #{link_to_function button_image("small/browse.gif", :alt => :browse),  "Application.Browser.browseFileFor('#{input_id_prefix}');", :class => "browse"}
              </div>
            </div>
        
            <div class="linked">
              <ul class="files">
                <li class="#{!media_file.blank? && media_file.referable_type.present? && media_file.file_type}"><div class="file">
                  <span class="referable_title">#{media_file_name}</span>
                  #{link_to_function button_image("small/browse.gif", :alt => :browse),  "Application.Browser.browseFileFor('#{input_id_prefix}');", :class => "browse"}
                  #{link_to_function t(:deselect, :scope => [:content,:editors,:file_browser]),  "Application.Browser.unlink('#{input_id_prefix}');", :class => "deselect"}
                </div></li>
              </ul>
            </div>
          </div>
        </div>
      </div>
EOF
  end
end    

