class Skyline::FormBuilderWithErrors < ActionView::Helpers::FormBuilder
  
  (field_helpers - %w(label fields_for radio_button check_box hidden_field) + %w(select collection_select time_zone_select date_select time_select datetime_select)).each do |selector|
    src = <<-end_src
      def #{selector}(method, *parms)
        wrap_with_error(method,*parms) do |parms|
          super(method,*parms)
        end
      end
    end_src
    class_eval src, __FILE__, __LINE__
  end  
  
  def label(method, text = nil, options = {})
    if @object.errors[method]
      super(method,text,options.merge(:class => "invalid #{options[:class]}".strip))
    else
      super
    end    
  end
  
  def label_with_text(method, options = {})
    self.label(method, self.t(method), options)
  end
  
  # Special field to handle automated reordering of elements (with help of NestedAttributesPositioning module)
  # Usage example:
  #   <% article_form.fields_for "sections_attributes", section, :index => guid do |s| %>
  #     <%= s.hidden_field :id unless s.object.new_record? %>
  #     <%= s.hidden_field :_destroy, :class => "delete" %>
  #     <%= s.positioning_field %>
  #     ...
  #   <% end %>
  # 
  # Will result in the following fields:
  #  <input type="hidden" name="article[sections_attributes][489e1519-56de-1e95-482b-bae29dd411ef][id]"      id="article_sections_attributes_489e1519-56de-1e95-482b-bae29dd411ef_id"      value="2211"/>
  #  <input type="hidden" name="article[sections_attributes][489e1519-56de-1e95-482b-bae29dd411ef][_destroy]" id="article_sections_attributes_489e1519-56de-1e95-482b-bae29dd411ef__destroy" class="delete"/>
  #  <input type="hidden" name="article[sections_position][]"                                                id="article_sections_position_489e1519-56de-1e95-482b-bae29dd411ef"           value="489e1519-56de-1e95-482b-bae29dd411ef"/>
  #
  def positioning_field
    name = self.object_name.sub(/\[([^\]]*)_attributes\]$/, "[\\1_position]") + "[]"
    value = options[:index]    
    raise "No options[:index] defined, need one to use for ordering correctly." unless value
    
    tag_id = name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "") + value.to_s

    @template.hidden_field_tag name, value, :id => tag_id
  end
  
  def has_error?(attribute)
    @object.errors[attribute].present?
  end
  
  def object_name_with_index
    if options[:index].present?
      self.object_name + "[#{options[:index]}]"
    else
      self.object_name
    end
  end
  
  # Wrap an input element with errors
  #
  # ==== Parameters
  # method<Symbol,String>:: The method to check for errors
  # *params:: The parameters to pass to the the block
  #
  # ==== Block
  # The return value of the block will be wrapped with the error
  # --
  def wrap_with_error(method,*parms,&block)
    options = parms.extract_options!
    method_options = options.except(:text_suffix)
    
    if @object.errors[method]
      method_options[:class] ||= ""
      method_options[:class] << " invalid"
    end
    
    parms << method_options if method_options.any?    
    html = yield(parms)
    html << options[:text_suffix] if options[:text_suffix]

    if @object.errors[method]
      html + fieldset_errors(method)
    else
      html
    end
    
  end
  
  
  def fieldset_errors(attribute)
    return unless @object.errors[attribute]
    out = []
    if errs = @object.errors[attribute]
      errs = [errs] if self.single_error_message?(errs)
      out = errs.map do |err|        
        @template.content_tag("div",err,:class => "error")
      end
    end
    out.join("\n")
  end
    
  def single_error_message?(errors)
    !errors.kind_of?(Array) || errors[1].kind_of?(Hash)
  end
  
  def dom_id(name,options={})
    CustomInstanceTag.new(@object_name, name, @template, objectify_options(options)).to_id(@options)
  end  
  
  def t(attribute_key_name, options = {})
    self.object.class.human_attribute_name(attribute_key_name.to_s, options)
  end
  
end

class CustomInstanceTag < ActionView::Helpers::InstanceTag
  def to_id(options={})
    options = options.stringify_keys
    name_and_id = options.dup
    add_default_name_and_id(name_and_id)
    options.delete("index")
    name_and_id["id"]
  end
end