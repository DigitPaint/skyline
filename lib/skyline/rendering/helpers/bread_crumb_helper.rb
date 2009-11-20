module Skyline::Rendering::Helpers::BreadCrumbHelper
  # ==== Parameters
  # bc<Array> :: An array of arrays with two elements: [[title,url],[title,url]...]
  #
  # ==== Options
  # :max_length<Integer> :: 
  #   Limit the max length in chars. Returns an array with nil element where 
  #   something has been cut away.
  def bread_crumb(bc,options={})
    if bc.kind_of? Skyline::ArticleVersion
      page = bc
      bc = bc.page.nesting.map{|p| [p.published_publication_data.navigation_title,p.url]}
      bc[-1][0] = page.data.navigation_title
    end
    
    if options[:max_length] && bc.size > 1
      # always display the last page
      b = [bc.pop]
      length = b[-1][0].size
            
      # then try to 'add' the first page if it fits
      first = nil
      if length + bc[0][0].to_s.size <= options[:max_length]
        first = bc.shift
        length += first[0].to_s.size
      end
      
      # try to add pages in between starting from the 2nd to last page and going back as long as it fits
      bc.reverse.each do |p|
        if length + p[0].to_s.size <= options[:max_length]
          b.unshift(p)
          length += p[0].to_s.size
        else
          b.unshift(nil)
          break
        end
      end
      
      b.unshift(first) if first
      b
    else
      bc
    end    
  end  
end