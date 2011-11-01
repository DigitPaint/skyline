# @private
module Skyline::ContentHelper

  # We need some preconditions to make automatic breadcrumbs work
  # 1. The last part is never clickable
  # 2. The part before last will be params[:return_to] if it's available
  # 3. Only lists will appear in the breadcrumb as links (unless there is return_to)
  def content_breadcrumb(stack)
    links = []
    return nil if stack.blank?
    types = stack.types.dup
    
    if types.last.last.nil?
      last = types.pop
    end
    
    types.each_with_index do |type,i|
      links << link_to(label_for(type), :action => "list", :types => stack.url_types(:up => (stack.types.size - i -1), :collection => true))
      links << "<span>#{stack.object_for_type(type).human_id}</span>"
    end
    
    links << "<span>#{label_for(last)}</span>" if last
    
    content_tag("div",("#{t(:breadcrumb_prefix, :scope => :content)} " + links.join(" &raquo; ")).html_safe ,:id => "breadcrumb")    
  end
  
  def label_for(type)
    obj = stack.object_for_type(type)
    obj.class.plural_name
  end
  
  def content_save_form(record_name,options={},&block)
    record = instance_variable_get("@#{record_name}")
    
    options.symbolize_keys!
    options.reverse_merge! :action => record.new_record? ? "create" : "edit"
    
    if record.class.publishable? || record.class.writable_fields.any?
    else
      
    end
    
  end
  
  def url_options_for_record(record,options={})
    options.symbolize_keys!
    defaults = {}
    defaults[:action] = (record.new_record? ? "create" : "edit")
        
    # Return to after save determination
    if record.class.settings.return_to_self_after_save
      defaults[:return_to] = "self"
    elsif params[:return_to]
      defaults[:return_to] = params[:return_to]
    end
    
    options.reverse_merge defaults
  end
  
  def content_form(record_name, options = {},&block)
    record = instance_variable_get("@#{record_name}")
    
    options = options.symbolize_keys
    url_options = url_options_for_record(record, {:action => options[:action]})
    
    contents = ''
    contents << content_fields(record.class, record_name, record)
    
    contents << capture(&block) if block_given?
		            
    if record.class.publishable? || record.class.writable_fields.any?
      contents << hidden_field_tag(:authenticity_token, form_authenticity_token)
#      contents << hidden_field(record_name, :id) unless record.new_record?
      contents << hidden_field_tag(:version,record.current_version)
      
      output = content_tag('form', contents.html_safe, :id => "contentform", :action => object_url(record,url_options), :method => 'post', :enctype => options[:multipart] ? 'multipart/form-data': nil)
               
    else
      output = content_tag('div', contents.html_safe, :id => "contentform")
    end
    

    # Postponed editors are editors like inline_list that should not be in the form but provide their own form/list
    # functionality.
    output << postponed_editors.map(&:output).join("\n") if postponed_editors.any?
    
    output
  end  

  def content_fields(fieldset, record_name, record)
    out = ""
    
    fieldset.each_field do |field|
      next if (field.hidden_in(:edit) && !record.new_record?) || 
              (field.hidden_in(:create) && record.new_record?)

      case field
        when Skyline::Content::MetaData::Field
          out << content_field(fieldset, record_name, field, record) + "\n"
        when Skyline::Content::MetaData::FieldGroup
          out <<  render(:partial => "skyline/content/group", :locals => {:title => field.singular_title, :content => content_fields(field, record_name, record)})
      end
    end
    out.html_safe
  end  
  
  def content_field(fieldset,record_name,field, record)
    e = Skyline::Editors::Editor.create(field,[record_name],record,self)
    if e.postpone?
      postponed_editors << e
      ""
    else
      e.output
    end
  end

  # Outputs an object list with the right presenter
  # defaults to Table currently.
  def presenter_for(records,fieldset)
    Skyline::Presenters::Presenter.create(fieldset.settings.presenter,records,fieldset,self).output
  end
  
  # Postponed editors are editors like inline_list that should not be in the form but provide their own form/list
  # functionality.  
  def postponed_editors
    @_postponed_editors ||= []
  end
    
  def boolean_field(tag_name, record, field, options = {})
    hidden_field_tag(tag_name, "0") + 
    record_with_errors(
      check_box_tag(tag_name, "1" , field.value(record), options),
      record,
      field)
  end
  
  def record_with_errors(content, record, field)
    if record.errors.on(field.attribute_name) 
      content_tag("div", content.html_safe, :class => "fieldWithErrors")
    else
      content
    end
  end
   
  def asset_url(path)
    File.join(@implementation.assets_url.to_s, path.to_s)
  end

  def input_name(*parts)
    parts = parts.flatten.compact.collect{|p| p.to_s}
    name = parts.shift.dup
    name << "[" + parts.join("][") + "]" unless parts.empty?
    name
  end 
  
  def input_id(*parts)
    parts.flatten.compact.collect{|p| p.to_s}.join("_")
  end  
  
end
