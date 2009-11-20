class Skyline::Editors::Heading < Skyline::Editors::Editor
  def output_without_errors
    text_field_tag(
      input_name(self.attribute_names), 
      field.value(record),
      :size => 40,
      :class => "heading",
      :style => params_to_styles(field.style),
      :id => input_id(self.attribute_names)
    )
  end
  
end