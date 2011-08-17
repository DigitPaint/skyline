# Provides error wrapping and some extra helper methods to working with labels and translations
# easier.
#
# Apart from adding new helper methods, this class overwrites the standard *_field 
# and *_select helpers. If one of the fields has an error, the validation errors for 
# that method are added just after the field. See {Skyline::FormBuilder#wrap_with_error} 
# for more information on what get's added.
class Skyline::FormBuilder < ActionView::Helpers::FormBuilder

  # Custom InstanceTag class from which we can extract the ID
  # @private
  class CustomInstanceTag < ActionView::Helpers::InstanceTag
    def to_id(options={})
      options = options.stringify_keys
      name_and_id = options.dup
      add_default_name_and_id(name_and_id)
      options.delete("index")
      name_and_id["id"]
    end
  end
  
  unless ActiveSupport::Dependencies.load_once_path?(__FILE__)
    ActiveSupport::Dependencies.autoloaded_constants << "Skyline::FormBuilder::CustomInstanceTag"
  end  
  
  # Overwrite all standard helpers with a wrapped version.
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
  
  # An improved version of the standard label helper it will append the class "invalid"
  # 
  # @see ActionView::Helpers::FormBuilder#label
  # 
  # @return [String]
  def label(method, text = nil, options = {})
    if @object.errors[method].present?
      super(method,text,options.merge(:class => "invalid #{options[:class]}".strip))
    else
      super
    end    
  end
  
  # Same as label but automatically translates the field name
  # 
  # @see Skyline::FormBuilder#t
  # 
  # @return [String]
  def label_with_text(method, options = {})
    self.label(method, self.t(method), options)
  end
  
  # Special field to handle automated reordering of elements (
  # with help of {Skyline::NestedAttributesPositioning} module)
  # 
  # @example Usage:
  #   <%= article_form.fields_for "sections_attributes", section, :index => 5 do |s| %>
  #     <%= s.hidden_field :id unless s.object.new_record? %>
  #     <%= s.hidden_field :_destroy, :class => "delete" %>
  #     <%= s.positioning_field %>
  #     ...
  #   <% end %>
  # 
  # @example Results in the following fields:
  #   <input type="hidden" name="article[sections_attributes][5][id]" id="article_sections_attributes_5_id"      value="2211"/>
  #   <input type="hidden" name="article[sections_attributes][5][_destroy]" id="article_sections_attributes_5__destroy" class="delete"/>
  #   <input type="hidden" name="article[sections_position][]"  id="article_sections_position_5" value="5"/>
  #
  def positioning_field
    name = self.object_name.sub(/\[([^\]]*)_attributes\]$/, "[\\1_position]") + "[]"
    value = options[:index]    
    raise "No options[:index] defined, need one to use for ordering correctly." unless value
    
    tag_id = name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "") + value.to_s

    @template.hidden_field_tag name, value, :id => tag_id
  end
  
  # Does the object have any errors set on an attribute.
  # 
  # @param attribute [String,Symbol] The attribute to check for errors
  # @return [Boolean] 
  def has_error?(attribute)
    @object.errors[attribute].present?
  end
  
  # Add the index of the current scope to the object_name if an index is used.
  #
  # @return [String] The object_name with an optional index added
  def object_name_with_index
    if options[:index].present?
      self.object_name + "[#{options[:index]}]"
    else
      self.object_name
    end
  end
  
  # Wrap an input element with errors, also appends "invalid" to the helpers
  # class. See {Skyline::FormBuilder#fieldset_errors} on how
  # the errors are added. 
  #
  # @param method [Symbol,String] The method/attribuet to check for errors
  # @param parms []
  # @param options [Hash] Options to pass to the original field helper, the key :text_suffix is stripped off
  # 
  # @option options :text_suffix () If you want text before the errors are 
  #   added you can set it by using text_suffix. This will be added immideately after the field.
  # 
  # @yield [parameters] The return value of the block will be wrapped with the error
  # @yieldparam [Hash] parameters The parameters to pass to the block (is the same as the parms of the method)
  # 
  # @return [String]
  def wrap_with_error(method,*parms,&block)
    options = parms.extract_options!
    method_options = options.except(:text_suffix)
    
    if @object.errors[method].present?
      method_options[:class] ||= ""
      method_options[:class] << " invalid"
    end
    
    parms << method_options if method_options.present?    
    html = yield(parms)
    html << options[:text_suffix] if options[:text_suffix]

    if @object.errors[method].present?
      html + fieldset_errors(method)
    else
      html
    end
    
  end
  
  # Generates a list of errors. Each error is wrapped in a 
  #   <div class="error">...</div>
  # 
  # @param attribute [String,Symbol] The attribute to get the errors for
  # @return [String,nil] A string containing each error in a div or nil if there are no errors.
  def fieldset_errors(attribute)
    return unless @object.errors[attribute].present?
    out = []
    if (errs = @object.errors[attribute]).present?
      errs = [errs] if self.single_error_message?(errs)
      out = errs.map do |err|        
        @template.content_tag("div",err,:class => "error")
      end
    end
    out.join("\n").html_safe
  end
  
  # The ID that a field for a certain field would get.
  #
  # @param attribute [String,Symbol] The attribute to use for the id
  # @return [String] A sting containing the ID for the field
  def dom_id(attribute,options={})
    CustomInstanceTag.new(@object_name, attribute, @template, objectify_options(options)).to_id(@options)
  end  
  
  # Translation for an attribute of that's used in this formbuilder. 
  # Uses {ActiveRecord::Base#human_attribute_name}
  # 
  # @param attribute [~to_s] The attribute to get the translation for
  # @param options [Hash] Options to pass to {ActiveRecord::Base#human_attribute_name}
  # @return [String] The translated attribute name.
  def t(attribute, options = {})
    self.object.class.human_attribute_name(attribute.to_s, options)
  end
  
  protected
  
  def single_error_message?(errors)
    !errors.kind_of?(Array) || errors[1].kind_of?(Hash)
  end  
  
end