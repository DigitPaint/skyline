class Skyline::AuthenticationsController < Skyline::ApplicationController
  layout false

  def new
  end
  
  def create
    if user = Skyline::Configuration.user_class.authenticate(params[:email], params[:password])      
      reset_session      
      session[:skyline_user_identification] = user.identification
      redirect_to skyline_root_path
    else
      messages.now[:error] = t(:error, :scope => [:authentication,:create,:flashes])
      render :action => :new
    end    
  end
  
  def destroy 
    session[:skyline_user_identification] = nil 
    if request.xhr?
      render(:update){|p| p.redirect_to new_skyline_authentication_path }
    else    
      redirect_to new_skyline_authentication_path
    end
  end    
  
  protected
  
  def protect?
    self.action_name == "destroy"
  end
end
