class Skyline::Content::Editors::EditableListController < Skyline::Skyline2Controller

  helper "skyline/content"
  before_filter :get_classes
  
  def new
    @object = @source_object.send(@assoc.name).build
    render :update do |p|
      editor = Skyline::Editors::EditableList.new(["element"],@source_object,@source_klass.fields[params[:association].to_sym],@template)
      p.insert_html :bottom, editor.js_object_name, editor.render_row(@object)
    end
  end
  
  protected
  
  def get_classes
    @source_klass = @implementation.content_class(params[:source_type])
    @source_object = @source_klass.find_by_id(params[:source_id]) || @source_klass.new    
    @assoc = @source_klass.reflect_on_association(params[:association].to_sym)
    @target_klass = @assoc.klass
  end
  
end
