class Skyline::Browser::ContentController < Skyline::ApplicationController
  def index
    if @content_selection = extract_valid_selection(params[:content_selection])
      
      if params[:referable_id].present?
        @content_type = params[:referable_type].constantize
        @selected_item = @content_type.find_by_id(params[:referable_id])
        @content_items = @content_type.published
      else
        @content_type = @content_selection.first
        @content_items = @content_type.published
      end
      
      render :partial => "index"
    else
      render :partial => "error"
    end
  end
  
  protected
  
  def extract_valid_selection(content_selection)
    return Skyline::Configuration.articles unless content_selection.present?
    
    result = []
    content_selection.split(',').each do |content|
      begin
        class_name = content.constantize
        result << class_name if Skyline::Configuration.articles.include? class_name
      rescue NameError
        return false
      end
    end
    
    result.any? ? result : false
  end
end