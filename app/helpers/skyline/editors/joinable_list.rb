class Skyline::Editors::JoinableList < Skyline::Editors::Editor
  
  attr_reader :target_class,:proxy_class, :reflection
  
  def initialize(names,record,field,template)
    super
    Rails.logger.debug("@attribute => #{@attribute_names.inspect}")

    @reflection = self.field.reflection
    if @reflection.macro == :has_many
      raise "JoinableList can only be used with HABTM and has_many :through associations" unless @reflection.through_reflection
      @target_class = reflection.klass
      @proxy_class = @reflection.through_reflection.klass
    elsif @reflection.macro == :has_and_belongs_to_many
      @target_class = @reflection.klass
      @proxy_class = nil
    else
      raise "JoinableList can only be used with HABTM and has_many :through associations (was: #{@reflection.macro})"
    end
  end
  
  def output_without_errors
    out = ""
    out << content_tag("ul",self.rows.join("\n"),:class => "joinable-list #{"orderable" if self.orderable?}", :id => js_object_name)
    out << browse_window
    out << hidden_field_tag(input_name(self.attribute_names + ["_order"]),records.map(&:id).join(","),:id => input_id(self.attribute_names + ["order"])) if(self.orderable?)
#    out << javascript_tag("var #{js_object_name} = new JoinableList('#{js_object_name}','#{input_id(self.attribute_names + ["order"])}')")
    out
  end      
  
  def orderable?
    @proxy_class && @proxy_class.respond_to?(:orderable?) && @proxy_class.orderable?
  end
    
  def render_row(row,proxy_id = nil)
    proxy_id ||= proxy_id(row)
    edit = hidden_field_tag(input_name(self.attribute_names + [proxy_id,"_target_id"]),target_id(row),:id => input_id(self.attribute_names + [proxy_id,"_target_id"]))
    edit << delete_button(proxy_id)
    
    out = ""
    out << "<span class=\"drag\">&nbsp;</span>" if self.orderable?        
    out << content_tag("div",edit,:class => "edit")
    out << "<div class=\"draggable\">"
    out << content_tag("div","<h3>#{title_for(row)}</h3>", :class => "content")
    out << content_tag("div","",:class => "clear")
    fields = content_fields(row.class,(self.attribute_names + [proxy_id]),row)
    out << content_tag("div",fields) unless fields.blank?
    out << "</div>"    
    content_tag("li",out,:id => row_id(proxy_id),:class => "#{cycle("odd","even")} element")
  end  
  
  def proxy_id(row)
    if @proxy_class
      row.new_record? ? random_prefix(row) : row.id
    else
      random_prefix(row)
    end
  end
  
  def random_prefix(row)
    "n_" + row.id.to_s + "_n" + Time.now.to_i.to_s + Time.now.usec.to_s 
  end
  
  def js_object_name
    "joinable_list_#{input_id(self.attribute_names)}"
  end  
  
  protected
  
  def target_id(row)
    if @proxy_class
      row.send(self.reflection.source_reflection.name).id
    else
      row.id
    end
  end
  
  def rows
    records.collect{|row| render_row(row)}
  end  
  
  def browse_window
    out = render(:partial => "skyline/content/editors/joinable_list/add", :locals => {:source_object => record, :association => field.name, :target_class => target_class})
    content_tag("div",out, :id => input_id(self.attribute_names,"browser"), :class => "browser-window")    
  end
  
  def records
    if @proxy_class
      @records ||= record.send(self.reflection.through_reflection.name).find(:all,:include => self.reflection.source_reflection.name)
    else
      @records ||= record.send(field.name)
    end
  end

  
  def delete_button(row_id)
    link_to_function image_tag("buttons/delete.gif", :alt => "remove"), 
                   "#{js_object_name}.remove('#{row_id(row_id)}');"
  end
  
  def row_id(id)
    input_id(self.attribute_names) + "_#{id}"
  end
  
  def assoc_class
    field.reflection.klass
  end
  
  def title_for(record)
    raise "Must have title_field defined in settings for #{target_class}" unless tf = target_class.settings.title_field
    raise "Title field #{tf} is not defined as field for #{target_class}" unless f = target_class.fields[tf]
    if @proxy_class
      f.value(record.send(self.reflection.source_reflection.name))
    else
      f.value(record)
    end
  end
end