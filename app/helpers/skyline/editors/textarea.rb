class Skyline::Editors::Textarea < Skyline::Editors::Editor
   def output_without_errors
     text_area_tag(
       input_name(self.attribute_names), 
       field.value(record), 
       :rows => 8,:cols => 50,
       :id => input_id(self.attribute_names),
       :style => params_to_styles(field.style)       
     )
   end
 end