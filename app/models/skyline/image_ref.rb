# @private
class Skyline::ImageRef < Skyline::InlineRef
  
  # Render html for specified RefObject
  # ==== Parameters
  # skyline_attr<Boolean>:: boolean that sets if skyline attributes should be added to the html tag
  #
  # ==== Returns
  # html image tag
  def to_start_html(skyline_attr = false,options={})
    options.reverse_merge! :nullify => false
    html_options = {}.merge(self.options)
    
    #TODO: get default image from options
    src = "broken.jpg"
    
    if self.referable_id.present? && image = self.referable_type.constantize.find_by_id(self.referable_id)
      if (html_options["width"].blank? || html_options["height"].blank?) && image.dimension
        html_options.reverse_merge! image.dimension
      end
      
      if html_options["width"].present? && html_options["height"].present?
        src = image.url("#{html_options["width"]}x#{html_options["height"]}")        
      else
        src = image.url
      end
    end
    
    skyline_ref_id = options[:nullify] ? "" : self.id
    
    if skyline_attr
      skyline_prefix = "/skyline"    
      html_options.update "skyline-ref-id" => skyline_ref_id, "skyline-referable-id" => self.referable_id, "skyline-referable-type" => self.referable_type
    end
    option_str = html_options.collect{|k,v| "#{k}=\"#{v}\""}.join(" ")
    
    html_str = "<img src=\"#{skyline_prefix}#{src}\" #{option_str} />"
  end
    
end
