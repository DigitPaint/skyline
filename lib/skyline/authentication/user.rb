# Use this module in your User model you want Skyline to use. By default Skyline
#  uses its own Skyline::User model, but you can specify your own using this
#  interface.
#
# @example Usage
#
# class User < ActiveRecord::Base
#   include Skyline::Authentication::User
#   
#   def self.authenticate(email, password)
#     self.first(:conditions => {:email => email.to_s.downcase, :password => encrypt(password.to_s)})
#   end
#   
#   def allow?(right_or_class, suffix = nil)
#     true
#   end
#   
#   def display_name
#     self.name.present? ? self.name : self.email
#   end
# end
#
module Skyline::Authentication::User

  def self.included(base)
    raise(TypeError, "Expected #{base.inspect} to be a subclass of ActiveRecord::Base") unless base < ActiveRecord::Base
    base.send(:has_many, :user_preferences, :class_name => "Skyline::UserPreference")
  end
    
  # Return the logged in user when successfully authenticated
  #
  # @see Skyline::Authentication::User For a usage example.
  #
  # @overload self.authenticate(email, password)
  #   @param email [String] The e-mail address or username of the user.
  #   @param password [String] The password the user entered.
  #
  # @return <User>:: an instance of the class this module includes
  def self.authenticate(email, password)
    raise "self.authenticate(email, password) is not implemented yet"
  end
  
  # Check if a user has a specific right
  #
  # @see Skyline::Authentication::User For a usage example.
  #
  # @overload allow?(right_or_class, suffix = nil)
  #   @param right_or_class [String,Symbol,~right_prefix] Can be a string or a symbol to check a 
  #     specific right, or you can pass an object that responds to #right_prefix, right_prefix must 
  #     return a string
  #   @param suffix [String,Symbol] A suffix to append to the right, mostly usefull in combination 
  #     with an object
  #
  # @return <Boolean>:: true if the right exists in one of the roles fo the user
  def allow?(right_or_class, suffix = nil)
    raise "allow?(right_or_class, suffix = nil) is not implemented yet"
  end
  
  # Display the name or e-mailaddress of the user for display purposes.
  #
  # @see Skyline::Authentication::User For a usage example.
  #
  # @overload display_name
  #
  # @return <String>:: The user's name to be displayed in Skyline
  def display_name
    raise "display_name is not implemented yet"
  end
end