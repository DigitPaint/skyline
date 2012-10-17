class Skyline::AuthenticationsController < Skyline::ApplicationController
  layout false

  def new
  end
  
  def create
    if user = Skyline::Configuration.user_class.find_by_identification(request.env["omniauth.auth"]["uid"])
      access_to_newsletter_ids = session[:access_to_newsletter_ids]
      reset_session
      session[:access_to_newsletter_ids] = access_to_newsletter_ids if access_to_newsletter_ids.present?
      session[:skyline_user_identification] = user.identification
      redirect_to skyline_root_path
    else
      messages.now[:error] = t(:error, :scope => [:authentication,:create,:flashes])
      render :action => :new
    end    
  end
  
  def destroy
    session[:skyline_user_identification] = nil
    redirect_to new_skyline_authentication_path
  end
  
  def fail
    if Skyline::Configuration.login_attempts_allowed > 0
      messages.now[:error] = t(:error_with_lockout, :scope => [:authentication,:create,:flashes])
    else
      messages.now[:error] = t(:error, :scope => [:authentication,:create,:flashes])
    end
    render :action => :new
  end
  
  protected
  
  def protect?
    self.action_name == "destroy"
  end
end
