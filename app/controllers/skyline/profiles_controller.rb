class Skyline::ProfilesController < Skyline::ApplicationController
  
  def edit
    
  end
  
  def update
    attributes = params[:user]
    current_user.force_password = attributes.andand.delete(:force_password)
    current_user.attributes = attributes
    current_user.editing_user = current_user
    
    # We use an instance variable because we want to use it in the render(:update) block.
    @saved = current_user.save
    
    if @saved
      notifications[:success] = t(:success, :scope => [:user,:profile,:flashes])
    else
      messages.now[:error] = t(:error,:scope => [:user,:profile,:flashes])
    end
  end
  
end