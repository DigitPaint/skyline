class Skyline::Media::FilesController < Skyline::ApplicationController
  
  before_filter :find_dir

  self.default_menu = :media_library
  
  authorize :create, :by => "media_file_create"
  authorize :edit, :update, :by => "media_file_update"
  authorize :destroy, :by => "media_file_delete"
  
  def index
  end
  
  def edit
    @file = @dir.files.find(params[:id])    
  end
  
  # We've got two different kinds of updates:
  # 1. The regular "update" through a form
  # 2. A drag action to a different directory.
  # 
  def update
    @file = @dir.files.find(params[:id])
    @file.attributes = params[:skyline_media_file]
    
    # We use an instance variable because we want to use it in the render(:update) block.
    @saved = @file.save

    if @saved
      notifications.now[:success] = t(:success, :scope => [:media, :files, :update, :flashes])
    else
      messages.now[:error] = t(:failed, :scope => [:media, :files, :update, :flashes])
    end    
  end
  
  def create
    @file = @dir.files.build(:name => params[:name], :data => params[:file])

    if @file.save
      render :json => {:jsonrpc => "2.0", :result => nil, :id => "id"}
    else
      render :json => {:jsonrpc => "2.0", :error => @file.errors.full_messages.to_sentence, :id => "id"}, :status => 200
    end
    
  end  
  
  def destroy
    @file = @dir.files.find(params[:id])
    @file.destroy
    notifications.now[:success] =  t(:success, :scope => [:media, :files,:destroy,:flashes])
    
    render :template => "/skyline/media/dirs/show"
  end

  protected
  
  def find_dir
    @dir = Skyline::MediaDir.find(params[:dir_id])
  end
  
end
