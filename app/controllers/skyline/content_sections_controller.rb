class Skyline::ContentSectionsController < Skyline::ApplicationController
  def new
    return unless request.xhr?
    render :update do |page|
      if params[:taggable_type].present?
        taggable = params[:taggable_type].constantize
        @tags = taggable.available_tags
        page.replace("section-#{params[:guid]}-tags", :partial => "tags", :locals => {:guid => params[:guid], :sectionable => taggable.new})
      else
        page.replace("section-#{params[:guid]}-tags", :text => "")
        page << "var myFx = new Fx.Scroll(\"contentEditPanel\").toBottom();"        
      end
    end
  end
end