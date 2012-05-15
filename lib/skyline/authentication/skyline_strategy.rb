require 'omniauth'

class Skyline::Authentication::SkylineStrategy
  include OmniAuth::Strategy
  
  option :fields, [:email, :password]
  
  def callback_phase
    user = Skyline::Configuration.user_class.authenticate(request.params['email'], request.params['password'])
    
    if user
      if user.allow_login_attempt?
        @user = user
        @user.reset_login_attempts! if Skyline::Configuration.login_attempts_allowed > 0
        super
      else
        fail!(:invalid_credentials)
      end
    else
      if Skyline::Configuration.login_attempts_allowed > 0
        attempting_user = Skyline::Configuration.user_class.find_by_email(request.params['email'])
        attempting_user.add_login_attempt! if attempting_user
      end
      fail!(:invalid_credentials)
    end
  end
  
  uid do
    @user.id
  end
end
  
# Override default failure endpoint as it raises an error in development
module OmniAuth
  class FailureEndpoint
    def call
      redirect_to_failure
    end
  end
end