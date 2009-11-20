require 'test_helper'
#require File.dirname(__FILE__) + '/../../db/fixtures/roles_and_rights.rb' 
require 'user_access_helper'

class MediaBrowserSuperAccessTest < ActionController::IntegrationTest
  include UserAccessHelper

  context "A Super user" do
    setup do            
      #TODO: figure out why it doesn't work if seed file is included at the top
      load File.dirname(__FILE__) + '/../../db/fixtures/roles_and_rights.rb' 
      build_complete_environment            
                  
      @role = Skyline::Role.find_by_name("super")
      
      @user.grants.create(:role => @role)
      assert_equal 1, @user.grants.size
      assert !@user.new_record?,@user.errors.inspect
            
      @u = login(@user,"qwedsa")
    end

    should "be able to access media browser" do
      @u.allow(:get, skyline_media_dirs_path)
    end
    
    should "be able to create a MediaDir" do
      @u.allow(:post, skyline_media_dirs_path)      
    end
     
    should "be able to edit a MediaDir" do
      @u.allow(:put, skyline_media_dir_path(@media_dir))      
    end    
     
    should "not be able to delete a MediaDir" do
      @u.allow(:delete, skyline_media_dir_path(@media_dir))      
    end 
     
    should "be able to create a MediaFile" do
      @u.allow(:post, skyline_media_dir_media_files_path(@media_dir),{:Filename => "/files/test.gif", :Filedata => fixture_file_upload("../../vendor/plugins/skyline/db/fixtures/files/test.gif", "image/gif")})
    end
      
    should "be able to edit a MediaFile" do
      @u.allow(:put,  skyline_media_dir_media_file_path(@media_dir,@media_file), {:Filename => "/files/test.gif", :mediafile => fixture_file_upload("../../vendor/plugins/skyline/db/fixtures/files/test.gif", "image/gif")})
    end    
      
    should "be able to delete a MediaFile" do
      @u.allow(:delete, skyline_media_dir_media_file_path(@media_dir,@media_file))
    end 
  end
  
end
