require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context "a user" do 
    setup do
      load File.dirname(__FILE__) + '/../../db/fixtures/roles_and_rights.rb' 
    
      @user = Factory(:user, :name => "Test User", :email => "test@test.com")
      assert !@user.new_record?
      @user.force_password!("qwedsa")
    end
  
    should "be allowed a right with his role" do 
      role = Skyline::Role.find_by_name("super")
      
      @user.grants.create(:role => role)    
    
      assert @user.allow?(:media_dir_create)
    end
  
    should "be able to have multiple roles" do
      role_1 = Skyline::Role.find_by_name("editor")
      role_2 = Skyline::Role.find_by_name("admin")
      
      @user.grants.create(:role => role_1)    
      @user.grants.create(:role => role_2)    
    
      assert_equal 2, @user.grants.size
    end
    
    should "be allowed a right if it's in one of his multiple roles" do
      role_1 = Skyline::Role.find_by_name("super")
      role_2 = Skyline::Role.find_by_name("super")

      @user.grants.create(:role => role_1)
      @user.grants.create(:role => role_2)

      assert @user.allow?(:media_dir_create)
      assert @user.allow?(:user_create) # only as an admin
    end
    
    context "that has been destroyed" do
      setup do
        @user = Factory(:user, :name => "destroyer", :email => "destroy@test.com")
        assert !@user.new_record?
        @user.force_password!("qwedsa")
        role = Skyline::Role.find_by_name("admin")
        @user.grants.create(:role => role)
        
        assert_equal 1, @user.grants.size
        assert !@user.destroyed?
        
        assert_equal @user, Skyline::User.authenticate("destroy@test.com","qwedsa")
        assert @user.destroy
      end
      
      should "set the destroyed flag on #destroy" do
        assert @user.destroyed?
      end
      should "not be removed from the database" do
        assert Skyline::User.find_by_id_and_destroyed(@user.id,true)
      end
      should "not be able to authenticate" do
        assert !Skyline::User.authenticate("destroy@test.com","qwedsa")
      end
      should "not have any grants" do
        user = Skyline::User.find_by_id(@user.id)
        assert_equal 0, user.grants.size
      end
    end
    
  end
end