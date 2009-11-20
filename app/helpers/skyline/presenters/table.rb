class Skyline::Presenters::Table < Skyline::Presenters::Presenter
  
  def output
    content_tag("table",super, :class => "listing")
  end
        
  def header
    "<thead><tr>#{self.heading_collection.map{|f| content_tag("th",f.singular_label.capitalize)}.join("\n")}<th></th><th></th></tr></thead>"
  end
  
  def body
    if self.collection.any?
      self.collection.map{|el| next if el.new_record?; content_tag("tr",self.row(el).join("\n"), :class => cycle("odd","even")) }
    else
      "<tr class=\"blank-slate\"><td colspan=\"#{self.heading_collection.size + 2}\">#{t(:blank_slate, :scope => [:content,:list], :class => self.fieldset.plural_name.downcase)}.</td></tr>"
    end
  end
  
  def row(record)
    return if record.new_record? # there can't be any new records in a list!
    content_cells = self.heading_collection.map do |field| 
      content,options = self.value(record,field); 
      content_tag("td",content,options)
    end
    
    [content_cells, content_tag("td",edit_button(record), :class => "edit"), content_tag("td",delete_button(record),:class => "delete")]
  end
  
        
end
