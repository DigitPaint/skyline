class Skyline::SettingsController < Skyline::Skyline2Controller
  
  layout "skyline/layouts/settings"
  
  self.default_menu_item = :admin
  
  authorize :index, :edit, :update, :by => :settings_update
  
  def index
    redirect_to edit_skyline_setting_path(@implementation.settings.page_names.first)
  end
  
  def edit
    @settings = @implementation.settings[params[:id]]
  end
  
  def update
    @settings = @implementation.settings[params[:id]]
    @settings.data = params[:settings]
    if @settings.save
      notifications[:success] = t(:success, :scope => [:settings, :update, :flashes])
      redirect_to edit_skyline_setting_path(@settings.page.name)
    else
      messages.now[:error] = t(:error, :scope => [:settings, :update, :flashes])
    end
  end
  
end
