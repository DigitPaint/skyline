class Skyline::AuthenticationsController < Skyline::ApplicationController
  layout false
  
  def new

  end
  
  def create
    if user = Skyline::User.authenticate(params[:email], params[:password])      
      reset_session      
      session[:user_id] = user.id
      redirect_to skyline_root_path
    else
      messages.now[:error] = t(:error, :scope => [:authentication,:create,:flashes])
      render :action => :new
    end
    
  end
  
  def destroy 
    session[:user_id] = nil 
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
