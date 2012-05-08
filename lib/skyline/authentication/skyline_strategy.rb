require 'omniauth'

class Skyline::Authentication::SkylineStrategy
  include OmniAuth::Strategy
  
  option :fields, [:email, :password]
  
  def callback_phase
    @user = Skyline::Configuration.user_class.authenticate(request.params['email'], request.params['password'])
    
    if @user
      super
    else
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