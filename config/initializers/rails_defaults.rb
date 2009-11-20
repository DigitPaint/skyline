ActionView::Base.field_error_proc = Proc.new {|html_tag, instance|  %(#{html_tag})}
ActionView::Base.default_form_builder = Skyline::FormBuilderWithErrors