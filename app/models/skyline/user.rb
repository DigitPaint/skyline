require 'bcrypt'

class Skyline::User < ActiveRecord::Base
  include Skyline::Authentication::User
  
  self.table_name = "skyline_users"
  has_many :grants, :class_name => "Skyline::Grant", :dependent => :delete_all
  has_many :roles, :class_name => "Skyline::Role", :through => :grants
  has_many :rights, :class_name => "Skyline::Right", 
    :finder_sql => proc{ "SELECT DISTINCT r.* FROM skyline_rights AS r, skyline_grants AS g JOIN skyline_rights_skyline_roles AS rr ON rr.role_id = g.role_id WHERE g.user_id = #{id} AND r.id = rr.right_id" }
  
  # This must be set to change the password (by the user himself)
  attr_accessor :current_password
  
  # This can be set by the admin to change the PW
  attr_reader :force_password
  attr_protected :force_password
  
  attr_accessor :skip_email_validation
  
  # This can be set to create initial users on the console or in test environments
  attr_accessor :skip_current_user_validation
  attr_protected :skip_current_user_validation
  
  attr_accessor :login_reset
  
  attr_accessor :editing_user
  
  validates_presence_of :password, :if => :password_changed?
  validates_presence_of :password_confirmation, :message => :confirmation, :if => :password_changed?, :on => :update
  validates_confirmation_of :password, :message => :confirmation, :if => :password_changed?
  
  validates_confirmation_of :force_password, :message => :confirmation, :if => lambda{|user| user.force_password.present?}
  
  validate :valid_email_address
  validates_uniqueness_of :email, :unless => :skip_email_validation
  
  validates_presence_of :grants
  
  validate :valid_values_for_editing_user, :unless => :skip_current_user_validation
  
  before_validation :reset_password_on_empty_current_password, :on => :update
  before_save :set_forced_password,:encrypt_password
  
  default_scope :order => "email ASC"
  
  accepts_nested_attributes_for :grants
  
  scope :authenticable, :conditions => {:is_destroyed => false}
  
  class << self
    
    # Authenticates a user with email and password
    #
    # ==== Returns
    # User:: The user if authentication passed
    # --
    def authenticate(username,password)
      return unless user = self.authenticable.find_by_email(username.to_s.downcase)
      return false unless user.allow?(:authentication_create)
      return false unless verify_password(user.password, password.to_s, user.encryption_method)
      user
    end
    
    def verify_password(password, verification, encryption_method)
      case encryption_method
      when "bcrypt"
        BCrypt::Password.new(password) == verification
      when "sha1"
        password == Digest::SHA1.hexdigest(verification)
      else
        raise 'Invalid encryption method'
      end
    end

    def find_by_identification(identification)
      self.find_by_id(identification)
    end
    
    def find_by_username(username)
      self.find_by_email(username)
    end
    
    def extract_valid_email_address(email)
      if email.kind_of? Mail::Address
        return email.address
      else
        begin
          address = Mail::Address.new(email.to_s)
        rescue
          return false
        end
      end
      if address && address.respond_to?(:domain) && address.domain
        return address.address 
      else
        return false
      end
    end  
    
    def per_page; 30; end      
    
  end
  
  def identification
    self.id
  end
  
  # Check if a user has a specific right
  #
  # ==== Parameters
  # right_or_class<String,Symbol,~right_prefix>:: 
  #   Can be a string or a symbol to check a specific right, or you can pass
  #   an object that responds to #right_prefix, right_prefix must return a string
  # suffix<String,Symbol>,::
  #   A suffix to append to the right, mostly usefull in combination with an object
  #
  # ==== Returns
  #<Boolean>:: true if the right exists in one of the roles fo the user
  # --
  def allow?(right_or_class,suffix=nil)
    if right_or_class.respond_to?(:right_prefix)
      right_or_class = right_or_class.right_prefix
    end
    
    right = [right_or_class,suffix].compact.map(&:to_s).join("_")
    
    @rights ||= self.rights.map{|r| r.name }.uniq
    @rights.include?(right)
  end
  
  def current_password=(v)
    changed_attributes.delete("password") if v.blank?
    @current_password = v
  end
  
  # Generate a new password, set it and return it.
  #
  # ==== Returns
  # String:: The newly set password
  # --
  def generate_new_password!
    pw = SimplePassword.new(8).to_s
    self.force_password!(pw)
  end
  
  # Forcefully set a password without any validations
  # Directly saves the object.
  # --
  def force_password!(pw)
    self.update_attribute(:password, pw)
    pw
  end
  
  def force_password=(pw)
    @force_password = pw if pw.present?
  end
  
  # Display the name or e-mailaddress of the user for
  # display purposes.
  def display_name
    self.name.present? ? self.name : self.email
  end
  
  # Don't really destroy the object, just
  # set the is_destroyed? flag.
  def destroy
    unless new_record?
      self.update_attributes(:is_destroyed => true)
      self.grants.collect {|g| g.destroy }
    end
    
    freeze
  end
      
  def viewable_roles
    if self.system?
      Skyline::Role.all
    else
      Skyline::Role.all(:conditions => {:system => false})
    end
  end
  
  # Reactivate user with these attributes, if they are valid
  def reactivate(attributes)
    temp_user = Skyline::User.new(attributes)
    temp_user.skip_email_validation = true
    temp_user.editing_user = self.editing_user
    if temp_user.valid?
      self.attributes = attributes
      self.force_password! attributes[:password]
      self.is_destroyed = false
      self
    else
      temp_user
    end
  end
  
  def allow_login_attempt?
    !self.is_locked?
  end
  
  def add_login_attempt!
    self.login_attempts = self.login_attempts + 1
    self.last_login_attempt = Time.now
    self.is_locked = true if self.login_attempts > Skyline::Configuration.login_attempts_allowed
    self.save
  end
  
  def reset_login_attempts!
    self.login_attempts = 0
    self.last_login_attempt = nil
    self.is_locked = false
    self.save
  end
  
  protected
  
  def set_forced_password
    self.password = @force_password if @force_password.present?
  end
  
  def encrypt_password
    return unless self.password_changed?
    self.password = BCrypt::Password.create(self.password.to_s)
    self.encryption_method = 'bcrypt'
  end
  
  def reset_password_on_empty_current_password
    changed_attributes.delete("password") if self.current_password.blank?
  end
  
  def valid_email_address
    return self.errors.add(:email,:invalid) if !Skyline::User.extract_valid_email_address(self.email)
  end
  
  def editing_myself
    self.editing_user == self
  end
  
  def valid_values_for_editing_user
    return self.errors.add :editing_user, :empty unless self.editing_user.present?
    
    # Only allow changed grants with roles allowed by the current user, never allow changes if editing own user
    self.grants.each do |g|
      if g.changed?
        self.errors.add :grants, :not_allowed unless self.editing_user.viewable_roles.include?(g.role)
        self.errors.add :grants, :changed if editing_myself
      end
    end
    
    # If editing own user, check password
    if editing_myself
      unless self.current_password && self.class.verify_password(self.password_was, self.current_password, self.encryption_method)
        self.errors.add(:current_password, :mismatch)
      end
    end
  end
  
end
