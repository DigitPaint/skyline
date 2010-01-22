class Skyline::User < ActiveRecord::Base
  set_table_name :skyline_users
  has_many :grants, :class_name => "Skyline::Grant", :dependent => :delete_all
  has_many :roles, :class_name => "Skyline::Role", :through => :grants
  has_many :rights, :class_name => "Skyline::Right", 
    :finder_sql => 'SELECT DISTINCT r.* FROM skyline_rights AS r, skyline_grants AS g JOIN skyline_rights_skyline_roles AS rr ON rr.role_id = g.role_id WHERE g.user_id = #{id} AND r.id = rr.right_id'
  
    
  # This must be set to change the password (by the user himself)
  attr_accessor :current_password
  
  # This can be set by the admin to change the PW
  attr_reader :force_password
  attr_protected :force_password
  
  # This can be set by the admin to force checking of the current password etc
  attr_accessor :editing_myself
    
  
  # Validations
  validate_on_update :valid_current_password, :if => :editing_myself

  validates_presence_of :password, :if => :password_changed?
  validates_presence_of :password_confirmation, :message => :confirmation, :if => :password_changed?, :on => :update
  validates_confirmation_of :password, :message => :confirmation, :if => :password_changed?

  validates_confirmation_of :force_password, :message => :confirmation, :if => lambda{|user| user.force_password.present?}
  
  validates_presence_of :email
  validate :valid_email_address
  validates_uniqueness_of :email, :unless => :is_destroyed

  validate :grants_didnt_change, :if => :editing_myself

  before_validation_on_update :reset_password_on_empty_current_password
  before_save :set_forced_password,:encrypt_password
  
  default_scope :order => "email ASC"
  
  accepts_nested_attributes_for :grants
  
  
  class << self
    
    # Authenticates a user with email and password
    #
    # ==== Returns
    # User:: The user if authentication passed
    # --
    def authenticate(email,password)
      user = self.first(:conditions => {:email => email.to_s.downcase, :password => encrypt(password.to_s), :is_destroyed => false})
      user && user || false
    end
    
    def encrypt(pw)
      Digest::SHA1.hexdigest(pw)
    end
    
    def extract_valid_email_address(email)
      if email.kind_of? TMail::Address
        return email.address
      else
        begin
          address = TMail::Address.parse(email.to_s)
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

  # Check if this users password matches.
  def correct_password?(password)
    if self.password_changed?
      self.password == password.to_s
    else
      self.password == self.class.encrypt(password.to_s)
    end
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
  def destroy_without_callbacks
    unless new_record?
      self.update_attributes(:is_destroyed => true)
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
  
  protected
  
  def set_forced_password
    self.password = @force_password if @force_password.present?
  end
  
  def encrypt_password
    return unless self.password_changed?
    self.password = self.class.encrypt(self.password.to_s)
  end

  def valid_current_password
    unless self.current_password && self.password_was == self.class.encrypt(self.current_password)
      self.errors.add(:current_password, :mismatch)
    end
  end

  def reset_password_on_empty_current_password
    changed_attributes.delete("password") if self.current_password.blank?
  end

  def valid_email_address
    return self.errors.add(:email,:invalid) if !Skyline::User.extract_valid_email_address(self.email)
  end
  
  def grants_didnt_change
    self.errors.add :grants, :changed if self.grants.detect{|g| g.changed?}
  end
end
