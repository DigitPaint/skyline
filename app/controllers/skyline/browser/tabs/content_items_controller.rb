class Skyline::Browser::Tabs::ContentItemsController < Skyline::ApplicationController
  
  def show
    @content_type = params[:id].singularize.camelize.constantize
    @content_items = @content_type.published
    @selected_item = @content_type.find_by_id(params[:referable_id])
  end
  
end