ActionView::Base.field_error_proc = Proc.new {|html_tag, instance|  %(#{html_tag})}

# This has to happen on every request as the Constant may not be the same anymore (because of reloading)
ActionController::Dispatcher.to_prepare(:form_builder) do
  ActionView::Base.default_form_builder = Skyline::FormBuilder
end