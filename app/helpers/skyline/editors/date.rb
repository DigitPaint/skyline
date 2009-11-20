module Skyline::Editors
  class Date < Editor
    def output_without_errors
      value = field.value(record)
      value ||= ::Date.today
      
      year_options = field.year_options || {}
      year_options.merge!({:field_name => "#{field.attribute_name}(1i)", :prefix => input_name(self.attribute_names[0..-2])})
      
      select_day(value, :field_name => "#{field.attribute_name}(3i)", :prefix => input_name(self.attribute_names[0..-2])) + 
      select_month(value, :field_name => "#{field.attribute_name}(2i)", :prefix => input_name(self.attribute_names[0..-2])) + 
      select_year(value, year_options)
    end
  end
end