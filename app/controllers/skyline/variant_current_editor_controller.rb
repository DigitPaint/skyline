class Skyline::VariantCurrentEditorController < Skyline::ApplicationController
  layout false
  
  def poll
    return render(:nothing => true) if session[:user_id].blank?
    
    response = {}
    data = Skyline::Variant.find_current_editor_for(params[:variant_id])
    current_user_is_editor = data["current_editor_id"].nil? || data["current_editor_id"].to_i == session[:user_id]

    if current_user_is_editor || Skyline::Variant.editor_idle_time < (Time.zone.now - data["current_editor_timestamp"])
      Skyline::Variant.update_current_editor(params[:variant_id],session[:user_id])
      response[:current_editor] = true
    else
      u = Skyline::User.find_by_id(data["current_editor_id"])
      response.update({
        :current_editor => false,
        :title => I18n.t(:dialog_title, :scope => [:variant_current_editor,:takeover]),
        :message => render_to_string(:partial => "skyline/articles/takeover_action", :locals => {:current_editor => u})
      })
    end

    
    render :text => response.to_json
  end
  
  def process(request,*args)
    logger.silence(ActiveSupport::BufferedLogger::Severity::FATAL){ super }
  end  
  
  protected

  def protect?
    false
  end
  
end
