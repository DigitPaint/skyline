class Skyline::Editors::Display < Skyline::Editors::Editor
  def output
    heading.to_s + (self.value || l(:content,:editors,:display,:empty))
  end
  
  def value
    case value = field.value(record)
      when Date,Time then value.to_formatted_s(:long)
      else value
    end
  end
end