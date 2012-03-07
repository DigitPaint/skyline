module Skyline::Editors
  class Editor
  
    class << self
      def create(field,name_chain,record,template)
        if field.editor 
          c = "Skyline::Editors::#{field.editor.to_s.classify}".constantize
          c.new(name_chain,record,field,template)
        else
          Skyline::Editors::TextField.new(name_chain,record,field,template)
        end
      rescue NameError => e
        Rails.logger.warn(" Editor instantiation error ".center(50,"="))
        Rails.logger.warn(e.to_s + "\n" + e.backtrace.join("\n"))
        Rails.logger.warn("=" * 50)
        Skyline::Editors::TextField.new(name_chain,record,field,template)
      end
    
    end
  
    attr_reader :field_names, :attribute_names, :field,:record
    def initialize(names,record,field,template)
      @record,@field,@template = record,field,template
      @field_names = (names.dup || []) << field.name
      @attribute_names = (names.dup || []) << field.attribute_name
    end
  
    def method_missing(method,*params)
      @template.send(method,*params)
    end
  
    # Should this editor be postponed until the form tag is closed?
    def postpone?; false; end
  
    # Convert a hash to CSS style definition
    #   {:height => 13, :width => "13px", :border_left => "1px solid red"}
    #   "height: 13px; width: 13px; border-left: 1px solid red;"
    def params_to_styles(opts)
      return "" if opts.nil?
      out = ""
      opts.each do |k,v|
        out << k.to_s.gsub("_","-") + ": "
        out << (v.kind_of?(Numeric) ? "#{v}px" : v.to_s )
        out << "; "
      end
      out
    end
  
    def output
      out = heading
      if self.respond_to? :output_without_errors
        out << field_with_errors([field_prefix, output_without_errors, field_suffix].join.html_safe)
      end
      content_tag("div",out.html_safe, :id  => "field_#{input_id(field_names)}", :class => "editor #{"invalid" if record.errors[field.attribute_name].any?}")
    end
  
    def errors
      errors = record.errors[field.attribute_name]
      if errors.kind_of?(Array)
        errors.flatten.to_sentence
      else
        errors
      end
    end
  
    def heading
      out = content_tag("h3",content_tag("label",(field.singular_title + " " + errors.to_s).html_safe, :for => input_id(attribute_names)))
      out << content_tag("p",field.description.html_safe ,:class => "description") unless field.description.blank?
      out
    end
  
    def field_with_errors(content)
      if self.record.errors[self.field.attribute_name].any?
        content_tag("div", content.html_safe, :class => "fieldWithErrors")
      else
        content
      end
    end      
  
    def field_prefix
      value = field_text(field.prefix)
      @template.content_tag("span",value.html_safe, :class => "prefix") if value.present?
    end
  
    def field_suffix
      value = field_text(field.suffix)    
      @template.content_tag("span",value.html_safe, :class => "suffix") if value.present?
    end
  
    def field_text(att)
      case att
        when Proc then perform_proc(att)
        else att.to_s
      end
    end
  
    def perform_proc(proc)
      case proc.arity
        when 1 then proc.call(record)
        when -1,0 then proc.call()
        else
          []
      end
    end      
  
  end
end