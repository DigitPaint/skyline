class Skyline::UsersController < Skyline::ApplicationController
  layout "skyline/layouts/settings"
  
  self.default_menu = :admin
  
  authorize :index, :by => "user_show"
  authorize :new,:create, :by => "user_create"
  authorize :edit,:update, :by => "user_update"
  authorize :destroy, :by => "user_delete"
  
  def index
    
    @users = Skyline::User.paginate(:per_page => self.per_page,:conditions => {:system => false, :is_destroyed => false}, :include => [:roles], :page => params[:page])
  end
  
  def new
    @user = Skyline::User.new(params[:user])
    @roles = current_user.viewable_roles
  end
  
  def create
    @user = Skyline::User.new(params[:user])
    
    if @user.save
      notifications[:success] = t(:success, :scope => [:user,:create,:flashes])
      javascript_redirect_to skyline_users_path(:page => page_number_for_user(@user))
    else
      @roles = current_user.viewable_roles
      messages.now[:error] = t(:error,:scope => [:user,:create,:flashes])
    end
    
  end
  
  def edit
    @user = Skyline::User.find_by_id(params[:id])
    @roles = current_user.viewable_roles    
  end  
  
  def update
    @user = Skyline::User.find_by_id(params[:id])
    @user.attributes = params[:user]
    @user.force_password = params[:user].andand[:force_password]
    @user.editing_myself = true if @user == current_user
    
    if @user.save
      notifications[:success] = t(:success, :scope => [:user,:update,:flashes])
      javascript_redirect_to skyline_users_path(:page => page_number_for_user(@user))
    else
      @roles = current_user.viewable_roles
      messages.now[:error] = t(:error,:scope => [:user,:update,:flashes])
    end
  end
  
  def destroy
    @user = Skyline::User.find_by_id(params[:id])
    if @user == current_user
      notifications[:error] = t(:cant_delete_myself, :scope => [:user,:destroy,:flashes])
    elsif @user.destroy
      notifications[:success] = t(:success, :scope => [:user,:destroy,:flashes])
    else
      notifications[:error] = t(:error, :scope => [:user,:destroy,:flashes])
    end 

    javascript_redirect_to skyline_users_path(:page => params[:page])
  end
  

  protected
  
  def per_page
    30
  end
  
  def page_number_for_user(user)
    (Skyline::User.count(:conditions => ["email < :email",{:email => user.email}]).to_i / self.per_page)  + 1
  end
  helper_method :page_number_for_user

end
