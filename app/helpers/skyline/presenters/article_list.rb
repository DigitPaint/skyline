class Skyline::Presenters::ArticleList < Skyline::Presenters::Presenter
    
  def output
    ["<div id=\"list-wrapper\"><ul class=\"article-list #{"orderable" if self.fieldset.orderable?}\" id=\"list\">",header,body,"</ul>",footer,"</div>"].join("\n")
  end
  
  def body
    if self.collection.any?
      self.collection.map{|el| self.row(el) }
    else
      "<li class=\"blank-slate\">#{t(:blank_slate, :scope => [:content,:list], :class =>  self.fieldset.plural_name.downcase)} " +
      link_to(t(:add_a_new, :scope => [:content], :class => self.fieldset.singular_name.downcase),:action => "create", :types => stack.url_types, :return_to => url_for({})) +
      "</li>"
    end
  end
  
  def footer
    if fieldset.orderable? && self.collection.any?
      <<-EOS
        <script type="text/javascript" charset="utf-8">
          var s = new Skyline.Sortable("list",{handle: "span.drag", clone: true, revert: true, draggables: "li.element"});
          s.addEvent("afterDrop", function(){
            #{
              remote_function(
                :url => {:action => "order", :types => stack.url_types},
                :data => "'order=' + Application.getSequence('#list li.element').join(',')"
              )            
            }
          });
        </script>
      EOS
    else
      ""
    end
  end
  
  
  #   <li class="header">
  #   <div class="draggable">
  #     <ul class="meta">
  #       <li style="width: 50%">Sub-pagina's</li>  
  #       <li style="width: 50%">Publicatiedatum</li>
  #     </ul>
  #   </div>
  # </li>
  def header
    out = "<li class=\"header\">"
    out << "<div class=\"edit\">&nbsp;</div>"    
    out << "<div class=\"draggable\">"
    out << "<div class=\"content\">&nbsp;</div>"
    out << "<ul class=\"meta\">"
    self.heading_collection.each do |field|
      out << "<li style=\"width: #{self.heading_size}\">#{field.singular_label}</li>"      
    end
    out << "</ul>"    
    out << "</div><div class=\"clear\">&nbsp;</div>"
    out << "</li>"
    if self.options[:navigation] && stack.has_parent?
      out << "<li class=\"up\">"+link_to(t(:up_one_level, :scope => [:content,:list]), :action => "list", :types => stack.url_types(:up => 1,:collection => true))+"</li>"
    end
    out
  end  
    
  # <li class="even">
  #   <span class="drag" ></span> 
  #   <div class="edit">
  #     <a href="#"><img src="/images/buttons/edit.gif?1197741337" alt="Edit"/></a>       
  #     <a href="#"><img src="/images/buttons/delete.gif?1197741337" alt="Edit"/></a>               
  #   </div>
  #   <div class="draggable">
  #     <div class="content">
  #       <h3>Titel van dit artikel</h3>
  #       <p>Some sub info.....</p>
  #     </div>
  #     <ul class="meta">
  #       <li style="width: 50%">7 items (view)</li>
  #       <li style="width: 50%">Publicatiedatum</li>
  #     </ul>
  #   </div>
  # </li>  
  def row(record)
    return if record.new_record? # there can't be any new records in a list!
    out = ""
    out << "<span class=\"drag\">&nbsp;</span>" if fieldset.orderable?
    out << content_tag("div",edit_button(record) + " " + delete_button(record),:class => "edit")
    out << "<div class=\"draggable\">"
    out << content(record)
    out << meta(record)
    out << "</div><div class=\"clear\">&nbsp;</div>"
    content_tag("li",out,:class => cycle("odd","even") + " element", :id => "element_#{record.id}")
  end
  
  def content(record)
    out = "<div class=\"content\">"
    title,opts = value(record,title_field)
    out << "<h3>#{title}</h3>"
    if subtitle_field
      subtitle,opts = value(record,subtitle_field)
      out << "<p>#{subtitle}</p>"
    end
    out << "</div>"    
  end
  
  def meta(record)
    out = "<ul class=\"meta\">"
    self.heading_collection.each do |field|
      v,rest = value(record,field)
      out << "<li style=\"width: #{self.heading_size}\">#{v.blank? ? "&nbsp;" : v}</li>"
    end
    out << "</ul>"
  end
  
  def heading_collection(fieldset=self.fieldset,cache=true)
    return @heading_collection if @heading_collection && cache
    @heading_collection = super.find_all{|f| ![self.title_field,self.subtitle_field].include?(f) }    
  end
  
  # We have to use 99% as to fool IE
  def heading_size
    @heading_size ||= "#{(99 / self.heading_collection.size.to_f).to_i}%"
  end
  
  # @deprecated: the use of title_column
  def title_field
    self.fieldset.fields[self.fieldset.settings.title_field || self.fieldset.settings.title_column || first_non_hidden_field]
  end

  # @deprecated: the use of subtitle_column
  def subtitle_field
    self.fieldset.settings.subtitle_field && self.fieldset.fields[self.fieldset.settings.subtitle_field] ||
    self.fieldset.settings.subtitle_column && self.fieldset.fields[self.fieldset.settings.subtitle_column] || 
    nil
  end
  
  def first_non_hidden_field
    self.fieldset.field_names.find{|f| self.fieldset.fields.has_key?(f) && !self.fieldset.fields[f].hidden_in(:list) }
  end
  
end