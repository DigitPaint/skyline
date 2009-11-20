class Skyline::Editors::InlineList < Skyline::Editors::Editor
  def postpone?; true; end
        
  def output
    klass = field.reflection.klass
    add_link = render(:partial => "add", :locals => {:klass => klass, :record => record, :field => field, :return_to => url_for({})})
    heading + add_link + Presenters::Presenter.create(field.presenter,field.value(record),klass,@template, :collection => field.attribute_name).output()
  end
end