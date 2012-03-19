class Skyline::VariantCurrentEditorController < Skyline::ApplicationController
  layout false
  
  skip_before_filter :handle_user_preferences
  
  def poll
    return render(:nothing => true) if session[:skyline_user_identification].blank?
    
    response = {}
    data = Skyline::Variant.find_current_editor_for(params[:variant_id])
    current_user_is_editor = data["current_editor_id"].nil? || data["current_editor_id"].to_i == session[:skyline_user_identification]

    if current_user_is_editor || Skyline::Variant.editor_idle_time < (Time.zone.now - data["current_editor_timestamp"])
      Skyline::Variant.update_current_editor(params[:variant_id],session[:skyline_user_identification])
      response[:current_editor] = true
    else
      u = Skyline::Configuration.user_class.find_by_identification(data["current_editor_id"])
      response.update({
        :current_editor => false,
        :title => I18n.t(:dialog_title, :scope => [:variant_current_editor,:takeover]),
        :message => render_to_string(:partial => "/skyline/articles/takeover_action.html", :locals => {:current_editor => u})
      })
    end

    
    render :text => response.to_json
  end
  
  def process(request,*args)
    old_level = Rails.logger.level
    Rails.logger.level = Logger::FATAL
    
    super
  ensure
    Rails.logger.level = old_level
  end  
  
  protected

  def protect?
    false
  end
  
end
