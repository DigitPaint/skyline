class Skyline::Editors::Boolean < Skyline::Editors::Editor
  def output_without_errors
    check_box_tag(input_name(self.attribute_names), "1" , field.value(record)) +
    hidden_field_tag(input_name(self.attribute_names), "0") + " " + field.singular_label   
  end
end