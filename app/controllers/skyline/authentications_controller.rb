class Skyline::AuthenticationsController < Skyline::ApplicationController
  layout false

  def new
    messages.now[:success] = t(:password_changed_successfully, :scope => [:authentication, :new, :flashes]) if params[:message]
  end
  
  # You can pass in the following from your authentication strategy:
  # 
  # @param [String,Integer] omniauth.auth.uid The User id to find
  # @param [Array] omniauth.auth.extra.keep_session_keys The session keys to keep after resetting the session
  def create
    if user = Skyline::Configuration.user_class.find_by_identification(request.env["omniauth.auth"]["uid"])

      # Store any keys found in ["omniauth.auth"]["extra"]["keep_session_keys"]
      session_values_before_reset = {}
      keep_keys = request.env["omniauth.auth"]["extra"]["keep_session_keys"]      
      if keep_keys && keep_keys.kind_of?(Array)
        keep_keys.each do |key|
          session_values_before_reset[key] = session[key]
        end
      end

      # Reset the session to prevent Session Injection attack
      reset_session
      
      # Restore the previously set keys
      if session_values_before_reset.present?
        session_values_before_reset.each do |k,v|
          session[k] = v
        end
      end
      
      session[:skyline_user_identification] = user.identification
      redirect_to skyline_root_path
    else
      messages.now[:error] = t(:error, :scope => [:authentication,:create,:flashes])
      render :action => :new
    end    
  end
  
  def destroy
    reset_session
    redirect_to new_skyline_authentication_path
  end
  
  def fail
    if Skyline::Configuration.login_attempts_allowed > 0
      messages.now[:error] = t(:error_with_lockout, :scope => [:authentication,:create,:flashes])
    else
      if params[:message] == "password_expired"
        messages.now[:error] = t(:error_with_invalid_credentials, :scope => [:authentication,:create,:flashes], :url => "#{ENTOPICMAIL_ADMIN_URL}/admin/renew_passwords/new?reason=password_expired&r=#{CGI.escape(new_skyline_authentication_path(:only_path => false, :message => 'password_changed_successfully'))}")
      else
        messages.now[:error] = t(:error, :scope => [:authentication,:create,:flashes])
      end
    end
    render :action => :new
  end
  
  protected
  
  def protect?
    self.action_name == "destroy"
  end
end
