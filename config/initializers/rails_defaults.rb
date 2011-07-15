Rails.application.config.action_view.field_error_proc = Proc.new {|html_tag, instance|  %(#{html_tag})}

# This has to happen on every request as the Constant may not be the same anymore (because of reloading)
ActionDispatch::Callbacks.to_prepare(:form_builder) do
  Rails.logger.warn "---> Call me!"
  Rails.application.config.action_view.default_form_builder = Skyline::FormBuilder
  ActionView::Base.default_form_builder = Skyline::FormBuilder
  

end