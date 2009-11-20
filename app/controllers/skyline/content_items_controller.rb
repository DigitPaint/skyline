class Skyline::ContentItemsController < Skyline::ApplicationController
  def new
    return unless request.xhr?
    render :update do |page|
      if params[:content_item_type].present?
        @content_item_class = params[:content_item_type].constantize
        page.replace_html("section-#{params[:guid]}-content-item-id", :partial => "content_item", :locals => {:guid => params[:guid], :sectionable => Skyline::Sections::ContentItemSection.new})
      else
        page.replace_html("section-#{params[:guid]}-content-item-id", :text => "")
        page << "var myFx = new Fx.Scroll(\"contentEditPanel\").toBottom();"        
      end
    end
  end
end