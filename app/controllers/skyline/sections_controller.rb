class Skyline::SectionsController < Skyline::ApplicationController
  before_filter :find_renderable_scope
    
  def new
    return unless request.xhr?
    
    @section = Skyline::Section.new
    @section.sectionable = params[:sectionable_type].constantize.new
    @section_guid = Guid.new    
  end
  
  protected
  def find_renderable_scope
    @renderable_scope = Skyline::Rendering::Scopes::Interface.unserialize(params[:renderable_scope]) if params[:renderable_scope]
    raise "Can't load renderable_scope from params[:renderable_scope]: '#{params[:renderable_scope]}'" unless @renderable_scope
  end
end