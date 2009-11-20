class Skyline::Editors::CheckableList < Skyline::Editors::Editor
  attr_reader :target_class
  
  def initialize(names,record,field,template)
    super
    
    reflection = self.field.reflection
    if reflection.macro == :has_and_belongs_to_many
      @target_class = reflection.klass
    else
      raise "CheckableList can only be used with HABTM associations (was: #{@reflection.macro})"
    end
  end
    
  def output_without_errors
    content_tag("div",
      content_tag("ul",self.render_records),
    :class => "checkable-list")
  end
  
  protected
  
  def render_records
    collection = @target_class.all
    if collection.any?
      collection.collect{|record| render_record(record)}.join("\n")
    else
      t(:blank, :scope => [:content,:editors, :checkable_list], :class => @target_class.plural_name.downcase)
    end
  end
  
  def render_record(row)
    proxy_id = random_prefix(row)
    
    check_box = check_box_tag(input_name(self.attribute_names + [proxy_id,"_target_id"]), row.id, field.value(record).include?(row), :id => input_id(self.attribute_names + [proxy_id,"_target_id"]))
    label = label_tag(input_name(self.attribute_names + [proxy_id,"_target_id"]), title_for(row))

    content_tag("li", check_box + label, :class => "#{cycle("odd","even")}", :id => row_id(proxy_id))
  end
  
  def random_prefix(row)
    "n_" + row.id.to_s + "_n" + Time.now.to_i.to_s + Time.now.usec.to_s 
  end
  
  def row_id(id)
    input_id(self.attribute_names) + "_#{id}"
  end
    
  def title_for(record)
    raise "Must have title_field defined in settings for #{target_class}" unless tf = target_class.settings.title_field
    raise "Title field #{tf} is not defined as field for #{target_class}" unless f = target_class.fields[tf]
    f.value(record)
  end  
end    
