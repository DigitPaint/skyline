# Use this module in your User model you want Skyline to use. By default Skyline
# uses its own Skyline::User model, but you can specify your own using this
# interface.
#
# @example Basic usage
#
#   class User < ActiveRecord::Base
#     include Skyline::Authentication::User
#   
#     def self.authenticate(username, password)
#       self.first(:conditions => {:email => username.to_s.downcase, :password => encrypt(password.to_s)})
#     end
#
#     def self.find_by_identification(identification)
#       self.find_by_id(identification)
#     end
#   
#     def identification
#       self.id
#     end
# 
#     def allow?(right_or_class, suffix = nil)
#       true
#     end
#   
#     def display_name
#       self.name.present? ? self.name : self.email
#     end
#   end
#
# @example Extended with automated account lockout
#
#   def allow_login?
#     self.login_attempts <= Skyline::Configuration.login_attempts_allowed
#   end
# 
#   def add_login_attempt!
#     self.login_attempts = self.login_attempts + 1
#     self.save
#   end
# 
#   def reset_login_attempts!
#     self.login_attempts = 0
#     self.save
#   end
#
#   def find_by_username(username)
#     self.find_by_email(username)
#   end

module Skyline::Authentication::User

  def self.included(base)
    raise(TypeError, "Expected #{base.inspect} to be a subclass of ActiveRecord::Base") unless base < ActiveRecord::Base
    base.send(:has_many, :user_preferences, :class_name => "Skyline::UserPreference", :foreign_key => :user_id)
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
  def self.authenticate(username, password)
    raise "self.authenticate(email, password) is not implemented yet"
  end
  
  # Return the unique identifier for this user (probably the DB id)
  #
  # @overload identification
  #
  # @return <Integer,String>:: an identification String or Integer
  def identification
    raise "identification is not implemented yet"
  end
  
  # Find user with provided identification
  #
  # @overload self.find_by_identification(identification)
  #   @param identification [Integer,String] The identification to find a user with (should match identification provided above).
  #
  # @return <User>:: an instance of the class this module includes with identifaction matching provided identification
  def self.find_by_identification(identification)
    raise "find_by_identification(identification) is not implemented yet"
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
  
  # Check if a user is allowed to log in. (Optional)
  # Override this function to implement additional login criteria, for instance to enable account lockout
  #
  # @see Skyline::Authentication::User For a usage example.
  #
  # @overload allow_login_attempt?
  #
  # @return <Boolean>:: true if the user is allowed to log in.
  def allow_login_attempt?
    true
  end
  
  # @!group Record login attempts
  #   - optional, mandatory if config.login_attempts_allowed is used.
  #
  # Called when user attempted to login, but failed.
  # @note Use this function if you wish to record (failed) login attempts.
  #   You MUST implement this functions if you want to use automatic account lockout in Skyline
  #   by setting config.login_attempts_allowed to something other than 0.
  #
  # @see #reset_login_attempts! reset_login_attempts!
  # @see #self.find_by_username(username) self.find_by_username
  #
  # @overload add_login_attempt!
  #   No return value, add login attempt to user and save object
  def add_login_attempt!
    
  end
  
  # Called when user login attempts should be reset to 0.
  # @note Use this function if you wish to record (failed) login attempts.
  #   You MUST implement this functions if you want to use automatic account lockout in Skyline
  #   by setting config.login_attempts_allowed to something other than 0.
  #
  # @see #add_login_attempt! add_login_attempt!
  # @see #self.find_by_username self.find_by_username
  #
  # @overload reset_login_attempts!
  #   No return value, reset user login attempts and save object
  def reset_login_attempts!
    
  end
  
  # Find user with username
  # @note Use this function if you want to add information to not logged in users, such as failed login attempts.
  #   You MUST implement this functions if you want to use automatic account lockout in Skyline
  #   by setting config.login_attempts_allowed to something other than 0.
  # @note A user returned found with this function has not logged in, this function should not be used for anything involving logged in users.
  #
  # @see #add_login_attempt! add_login_attempts
  # @see #reset_login_attempts! reset_login_attempts!
  #
  # @overload self.find_by_username(username)
  #   @param username [String] The username for which a user is found.
  #
  # @return <User>:: The user object identified by the provided username
  def self.find_by_username(username)
    
  end
  # @!endgroup
  
end