class Skyline::LocalesController < Skyline::ApplicationController

  def show
    locale = params[:id]
    unless @locale = I18n.t("tinymce", :locale => (locale || I18n.locale))
      render :nothing => true, :status => :not_found
    end
  end
  
  protected
  
  def protect?
    false
  end
end
