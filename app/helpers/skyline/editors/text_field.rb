class Skyline::Editors::TextField < Skyline::Editors::Editor
  def output_without_errors
   text_field_tag(
     input_name(self.attribute_names), 
     field.value(record),
     :size => 40,
     :id => input_id(self.attribute_names),
     :style => params_to_styles(field.style),
     :class => "full"
   )
  end
end    
