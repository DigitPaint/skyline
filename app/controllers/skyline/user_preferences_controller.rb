class Skyline::UserPreferencesController < Skyline::ApplicationController
  def create
    unless params[:skyline_up].blank?
      user_preference = ActiveSupport::JSON.decode(params[:skyline_up])
      
      if user_preference.values.first == "_delete"
        current_user.user_preferences.remove(user_preference.keys.first)
        up = {}
      else
        current_user.user_preferences.set(user_preference.keys.first, user_preference.values.first)
        up = {user_preference.keys.first => user_preference.values.first}
      end
    end
    respond_to do |format|
      format.json  { render :json => up }
    end
  end
end