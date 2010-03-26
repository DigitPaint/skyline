class Skyline::SectionsController < Skyline::ApplicationController
  before_filter :find_renderable_scope
    
  def new
    return unless request.xhr?
    render :update do |page|
      section = Skyline::Section.new
      section.sectionable = params[:sectionable_type].constantize.new
      section_guid = Guid.new
      
      fields_for params[:object_name] do |variant_form|
        page.insert_html(:bottom, "contentlist", :partial => "form", :locals => {:variant_form => variant_form, :section => section, :guid => section_guid})
      end
      page << "$('contentlist').retrieve('application.sections').addSection('section_#{section_guid}');"
      page << "var myFx = new Fx.Scroll(\"contentEditPanel\").toBottom();"
    end
  end
  
  protected
  def find_renderable_scope
    @renderable_scope = Skyline::Rendering::Scopes::Interface.unserialize(params[:renderable_scope]) if params[:renderable_scope]
    raise "Can't load renderable_scope from params[:renderable_scope]: '#{params[:renderable_scope]}'" unless @renderable_scope
  end
end