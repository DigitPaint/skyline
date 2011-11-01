class Skyline::ContentSectionsController < Skyline::ApplicationController
  def new
    if params[:taggable_type].present?
      @taggable = params[:taggable_type].constantize
      @tags = @taggable.available_tags
    end
  end
end