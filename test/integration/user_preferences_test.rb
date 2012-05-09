require 'test_helper'
require 'user_access_helper'

class UserPreferencesTest < ActionController::IntegrationTest
  include UserAccessHelper
  include Skyline::Engine.routes.url_helpers
  
  context "User preferences" do
    setup do
       @user = FactoryGirl.create(:user)
       @user.force_password!("qwedsa")
       
       @user.user_preferences << FactoryGirl.create(:user_preference, :key => "a.", :encoded_value => 1.to_yaml)
       
       @u = login(@user,"qwedsa")
    end
    
    should "be stored in a cookie with value and sent on request" do
      @u.cookies["skyline_up"] = ActiveSupport::JSON.encode({"my_field" => "a.email@address.com"})
      @u.get "/skyline"
      @u.assert_equal('a.email@address.com', @user.user_preferences.get('my_field'))
    end
    
    should "be stored in a cookie with serialized hash and sent on request" do
      up_my_hash = {'a' => 1, 'b' => 2}
      @u.cookies["skyline_up"] = ActiveSupport::JSON.encode({"my_hash" => up_my_hash})
      @u.get "/skyline"
      @u.assert_equal(up_my_hash, @user.user_preferences.get('my_hash'))
    end

    should "be able to collect multiple values and send after request" do
      @u.cookies["skyline_up"] = ActiveSupport::JSON.encode({"my_field" => "a.email@address.com", "my_hash" => {'a' => 1, 'b' => 2}})
      @u.get "/skyline"  
      @u.assert_equal({'a' => 1, 'b' => 2}, @user.user_preferences.get('my_hash'))
      @u.assert_equal('a.email@address.com', @user.user_preferences.get('my_field'))
    end
    
    should "have empty value in cookie after request" do
      @u.cookies["skyline_up"] = ActiveSupport::JSON.encode({"my_field" => "a.email@address.com"})
      @u.cookies["my_own_field"] = "Do not delete me"
      
      @u.get "/skyline"
          
      @u.assert("", cookies["skyline_up"])
      @u.assert("Do not delete me", cookies["my_own_field"])
    end
    
    should "be able to be set through controller" do
      @u.post "skyline/user_preferences",
            'skyline_up' => ActiveSupport::JSON.encode({"my_hash" => {"a" => 1, "b" => 2}})
                    
      @u.assert_equal({'a' => 1, 'b' => 2}, @user.user_preferences.get('my_hash'))     
    end
    
    should "be able to delete through controller" do
      @u.assert @user.user_preferences.has_key?("a")
      @u.post "skyline/user_preferences", 
            'skyline_up' => ActiveSupport::JSON.encode({"a" => "_delete"})
                    
      @u.assert !@user.user_preferences.has_key?("a")
    end
    
    should "store delete value in cookie and handle correctly" do
      @u.assert @user.user_preferences.has_key?("a")
      @u.cookies["skyline_up"] = ActiveSupport::JSON.encode({"_delete" => ["a","b"]})
      
      @u.get "/skyline"
      
      @u.assert !@user.user_preferences.has_key?("a")
      @u.assert !@user.user_preferences.has_key?("b")
    end
    
    
  end
end