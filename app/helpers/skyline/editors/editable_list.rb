class Skyline::Editors::EditableList < Skyline::Editors::Editor

  attr_reader :target_class, :reflection
  
  def initialize(names,record,field,template)
    super
#    @attribute_names[-1] = "skyline_#{@attribute_names[-1]}"
    
    @reflection = self.field.reflection
    if @reflection.macro == :has_many
      @target_class = reflection.klass
    else
      raise "EditableList can only be used with has_many associations (was: #{@reflection.macro})"
    end
  end
  
  def output_without_errors
    out = ""
    out << content_tag("ul",self.rows.join("\n"),:class => "editable-list", :id => js_object_name)
    out << content_tag("div",add_new_link, :class => "add", :id => "#{js_object_name}_add")
    out << hidden_field_tag(input_name(self.attribute_names << "-1"),"0")
  end  
  
  def render_row(row)
    field_id = row.new_record? ? random_prefix(row) : row.id
    
    edit = ""
    edit << delete_button(field_id)
    
    header = content_tag("div",edit,:class => "tools")
    header << "#{@target_class.singular_name} #{row.human_id}"
    
    out = ""
    out << content_tag("div",header,:class => "head")
    fields = content_fields(row.class,(self.attribute_names + [field_id]),row)
    out << content_tag("div",fields,:class => "body") unless fields.blank?
    content_tag("li",content_tag("div",out,:class => "section"),:id => row_id(field_id),:class => "#{cycle("odd","even")} element")
  end  
  
  def js_object_name
    "editable_list_#{input_id(self.attribute_names)}"
  end  
  
  
  protected
  
  def add_new_link
    link_to_remote(t(:add_more, :scope => [:content], :class => @target_class.plural_name), {
      :url => {:controller => "skyline/content/editors/editable_list", 
               :action => "new", 
               :source_type => self.record.class.to_s.demodulize.underscore, 
               :source_id => self.record,
               :association => self.field},
			:loading => "Application.toggleSpin('#{js_object_name}_add','#{t(:loading, :scope => [:global])}')",
			:complete => "Application.toggleSpin('#{js_object_name}_add')" 
    }, :class => "add")
  end
  
  
  def random_prefix(row)
    "n_" + row.id.to_s + "_n" + Time.now.to_i.to_s + Time.now.usec.to_s 
  end  
  
  def records
    @records ||= record.send(field.name)
  end
    
  def row_id(id)
    input_id(self.attribute_names) + "_#{id}"
  end  
  
  def rows
    records.collect{|row| render_row(row)}
  end  

  def delete_button(row_id)
    link_to_function image_tag("/skyline/images/buttons/section-delete.gif", :alt => "remove"), 
                   "$('#{row_id(row_id)}').dispose();"
  end

end