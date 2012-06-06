require 'test_helper'
require File.dirname(__FILE__) + '/../../db/fixtures/roles_and_rights.rb' 
require 'user_access_helper'

class MediaBrowserUserAccessTest < ActionController::IntegrationTest
  include UserAccessHelper
  include Skyline::Engine.routes.url_helpers
  fixtures :all
  
  context "A User" do
    setup do
      #TODO: figure out why it doesn't work if seed file is included at the top
      # load File.dirname(__FILE__) + '/../../db/fixtures/roles_and_rights.rb' 
      build_complete_environment
      
      # Grant was already assigned on create
      assert_equal 1, @user.grants.size
      assert !@user.new_record?,@user.errors.inspect
            
      @u = login(@user,"qwedsa")
      
    end
 
    should "not be able to create a MediaDir" do
      @u.deny(:post, skyline_media_dirs_path)      
    end
     
    should "not be able to edit a MediaDir" do
      @u.deny(:put, skyline_media_dir_path(@media_dir))      
    end    
     
    should "not be able to delete a MediaDir" do
      @u.deny(:delete, skyline_media_dir_path(@media_dir))      
    end 
     
     should "not be able to create a MediaFile" do
       @u.deny(:post, skyline_media_dir_files_path(@media_dir),{:name => "/files/test.gif", :file => fixture_file_upload(File.dirname(__FILE__) + "/../../db/fixtures/files/test.gif", "image/gif")})
     end
      
    should "not be able to edit a MediaFile" do
     @u.deny(:put,  skyline_media_dir_file_path(@media_dir,@media_file), {:name => "/files/test.gif", :file => fixture_file_upload(File.dirname(__FILE__) + "/../../db/fixtures/files/test.gif", "image/gif")})
    end
      
    should "not be able to delete a MediaFile" do
     @u.deny(:delete, skyline_media_dir_file_path(@media_dir,@media_file))
    end
    
  end  
  
end
