module UserAccessHelper
  module UserAssertion
    def allow(http_method,path,params={})
      send(http_method,path,params)
      assert((response.success? || response.redirect?), "Response was #{response.inspect}")
    end
    
    def deny(http_method,path,params={})
      send(http_method,path,params)
      assert_response :unauthorized
    end
  end
  

  def login(user,pw)
    open_session do |s|
      s.extend(UserAssertion)
      s.post "/skyline/authentication", :email => user.email, :password => pw      
    end    
  end
  
  def build_complete_environment
    @media_dir = FactoryGirl.create(:media_dir, :type => "Skyline::MediaDir")
    assert !@media_dir.new_record?
    
    @media_sub_dir = FactoryGirl.create(:media_dir, :type => "Skyline::MediaDir", :directory => @media_dir)
    assert !@media_sub_dir.new_record?
    
    @media_file = FactoryGirl.create(:media_file, :parent_id => @media_dir.id, :type => "Skyline::MediaFile")
    assert !@media_file.new_record?
    
    @user = FactoryGirl.create(:user, :name => "Test User", :email => "test@test.com")
    assert !@user.new_record?
    @user.force_password!("qwedsa")
  end
end
