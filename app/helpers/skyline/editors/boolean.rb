class Skyline::Editors::Boolean < Skyline::Editors::Editor
  def output_without_errors
    hidden_field_tag(input_name(self.attribute_names), "0") + 
    check_box_tag(input_name(self.attribute_names), "1" , field.value(record)) + " " + field.singular_label  
  end
end