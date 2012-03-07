module Skyline::FormHelper
  
  def skyline_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    with_custom_field_error_proc do
      self.form_for(record_or_name_or_array, *(args << options.merge(:builder => Skyline::FormBuilder)), &proc)    
    end
  end
  
  def skyline_fields_for(record_or_name_or_array, *args, &block)
    options = args.extract_options!
    args = [nil] if args == []
    with_custom_field_error_proc do
      self.fields_for(record_or_name_or_array, *(args << options.merge(:builder => Skyline::FormBuilder)), &proc)    
    end    
  end
  
  
  protected
  
  # Override the default ActiveRecordHelper behaviour of wrapping the input.
  # This gets taken care of semantically by adding an error class to the LI tag
  # containing the input.
  # @private
  FIELD_ERROR_PROC = proc do |html_tag, instance_tag|
    html_tag
  end

  def with_custom_field_error_proc(&block)
    default_field_error_proc = ::ActionView::Base.field_error_proc
    ::ActionView::Base.field_error_proc = FIELD_ERROR_PROC
    yield
  ensure
    ::ActionView::Base.field_error_proc = default_field_error_proc
  end  
  
end