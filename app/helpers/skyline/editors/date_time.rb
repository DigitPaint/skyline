class Skyline::Editors::DateTime < Skyline::Editors::Editor
  def output_without_errors
    value = field.value(record)
    value ||= Time.now
    select_day(value, :field_name => "#{field.attribute_name}(3i)", :prefix => input_name(self.attribute_names[0..-2])) + 
    select_month(value, :field_name => "#{field.attribute_name}(2i)", :prefix => input_name(self.attribute_names[0..-2])) + 
    select_year(value, :field_name => "#{field.attribute_name}(1i)", :prefix => input_name(self.attribute_names[0..-2])) + " &mdash; ".html_safe +
    select_hour(value, :field_name => "#{field.attribute_name}(4i)", :prefix => input_name(self.attribute_names[0..-2])) + " : " +
    select_minute(value, :field_name => "#{field.attribute_name}(5i)", :prefix => input_name(self.attribute_names[0..-2]))
  end
end