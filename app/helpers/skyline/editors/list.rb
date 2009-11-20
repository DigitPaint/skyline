class Skyline::Editors::List < Skyline::Editors::Editor
  def output_without_errors
    select_tag(input_name(self.attribute_names),option_tags)       
  end
  
  private
  def option_tags
    list = case field.list
      when Array, Hash : field.list
      when Proc : perform_proc(field.list)
    end
    options_for_select(list,field.attribute_value(self.record))
  end
    
end