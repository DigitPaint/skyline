class Skyline::LinkRef < Skyline::InlineRef
  
  # Render html start tag for specified RefObject
  # ==== Parameters
  # skyline_attr<Boolean>:: boolean that sets if skyline attributes should be added to the html tag
  #
  # ==== Returns
  # String:: html link tag
  def to_start_html(skyline_attr = false,options={})
    options.reverse_merge! :nullify => false
    skyline_attr_str = ""
    
    href = "broken"
    if !self.referable_id.blank?
      linked_file = self.referable_type.constantize.find_by_id(self.referable_id)
      href = linked_file.url unless linked_file.blank?
    end
    skyline_ref_id = options[:nullify] ? "" : self.id
    skyline_attrs = "skyline-ref-id=\"#{skyline_ref_id}\" skyline-referable-id=\"#{self.referable_id}\" skyline-referable-type=\"#{self.referable_type}\"" if skyline_attr    
    options = self.options.collect{|k,v| "#{k}=\"#{v}\""}.join(" ")
        
    html_str = "<a href=\"#{href}\" #{options} #{skyline_attrs}>"
  end
  
  # Render html end tag for specified RefObject
  # ==== Parameters
  # skyline_attr<Boolean>:: boolean that sets if skyline attributes should be added to the html tag
  #
  # ==== Returns
  # String:: html link closing tag
  def to_end_html
    html_str = "</a>"
  end
end