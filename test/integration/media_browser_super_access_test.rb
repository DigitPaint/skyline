require 'test_helper'
require File.dirname(__FILE__) + '/../../db/fixtures/roles_and_rights.rb' 
require 'user_access_helper'

class MediaBrowserSuperAccessTest < ActionController::IntegrationTest
  include UserAccessHelper
  include Skyline::Engine.routes.url_helpers
  
  context "A Super user" do
    setup do            
      #TODO: figure out why it doesn't work if seed file is included at the top
      # load File.dirname(__FILE__) + '/../../db/fixtures/roles_and_rights.rb' 
      build_complete_environment            
                  
      @role = Skyline::Role.find_by_name("super")
      @user.grants.create(:role_id => @role.id)
      
      # A dummy grant was assigned on create
      assert_equal 2, @user.grants.size
      assert !@user.new_record?,@user.errors.inspect
            
      @u = login(@user,"qwedsa")
    end

    should "be able to access media browser" do
      @u.allow(:get, skyline_media_dirs_path)
    end
    
    should "be able to create a MediaDir" do
      @u.allow(:post, skyline_media_dirs_path, {:parent_id => @media_dir.id, :name => "create_test"})
    end
     
    should "be able to edit a MediaDir" do
      @u.allow(:put, skyline_media_dir_path(@media_dir))      
    end    
     
    should "be able to delete a MediaDir" do
      @u.allow(:delete, skyline_media_dir_path(@media_sub_dir))      
    end 
     
    should "be able to create a MediaFile" do
      @u.allow(:post, skyline_media_dir_files_path(@media_dir),{:name => "/files/test.gif", :file => fixture_file_upload(File.dirname(__FILE__) + "/../../db/fixtures/files/test.gif", "image/gif"), :format => :js})
    end
      
    should "be able to edit a MediaFile" do
      @u.allow(:put,  skyline_media_dir_file_path(@media_dir,@media_file), {:name => "/files/test.gif", :file => fixture_file_upload(File.dirname(__FILE__) + "/../../db/fixtures/files/test.gif", "image/gif"), :format => :js})
    end    
      
    should "be able to delete a MediaFile" do
      @u.allow(:delete, skyline_media_dir_file_path(@media_dir,@media_file), :format => :js)
    end 
  end
  
end
