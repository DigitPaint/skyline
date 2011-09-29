class Skyline::ContentItemsController < Skyline::ApplicationController
  def new
    return unless request.xhr?
    if params[:content_item_type].present?
      @content_item_class = params[:content_item_type].constantize
    end    
  end
end