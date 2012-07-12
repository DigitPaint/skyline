class Skyline::Editors::Wysiwyg < Skyline::Editors::Editor
  def output_without_errors
    out = content_tag("div",text_area_tag(
      input_name(self.attribute_names), 
      record.send(field.name), 
      :class => "wysiwyg", 
      :rows => 15,
      :id => self.tag_id,
      :style => "width: 100%; height: 5px; #{params_to_styles(field.style)}"
    ).html_safe, :class => "section")
    out << self.tinymce_js
  end
  
  def tag_id
    "wysiwyg" + self.attribute_names.join("_")
  end
  
  def tinymce_js
    javascript_tag "new Skyline.Editor('#{self.tag_id}',{
      contentCss : '#{Skyline::Configuration.url_prefix}/stylesheets/wysiwyg.css',
      #{"enableEditHtml : true," if current_user.allow?("tinymce_edit_html")}
      language : Application.locale    
    })"
  end
  

end