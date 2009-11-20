class Skyline::Editors::Textile < Skyline::Editors::Editor
  def output_without_errors
    text_area_tag(
      input_name(self.attribute_names), 
      field.value(record), 
      :rows => 8,
      :cols => 50, 
      :class => "textile",
      :style => params_to_styles(field.style)
    ) + content_tag("div", "You can use textile syntax to format your text. See <a href=\"http://hobix.com/textile/\" target=\"_blank\">the syntax rules for help</a>.")
  end      
end