class Skyline::ApplicationController < ApplicationController
  include Skyline::TranslationHelper
  
  before_filter :set_locale
  before_filter :authenticate_user, :identifier => :authentication
  before_filter :handle_user_preferences, :identifier => :preferences
  before_filter :authorize_user_for_action, :identifier => :authorization
  
  around_filter Skyline::ArticleVersionObserver.instance
  
  class_attribute :default_menu
  attr_accessor :current_menu
  hide_action :default_menu, :default_menu=, :current_menu, :current_menu=, :menu, :javascript_redirect_to
  

  # Load all helpers
  Dir[Skyline.root + "app/helpers/**/*_helper.rb"].each do |helper|
    helper helper.sub(/^#{Regexp.escape((Skyline.root + "app/helpers/").to_s)}/,"").sub(/_helper\.rb$/,"")
  end
  
  # Load all plugin helpers so they can override stuff.
  Dir[Rails.application.config.skyline_plugins_manager.plugin_path + "*/app/helpers/**/*_helper.rb"].each do |helper|
    helper helper.sub(/^#{Regexp.escape(Rails.application.config.skyline_plugins_manager.plugin_path.to_s)}\/?.+?\/app\/helpers\//,"").sub(/_helper\.rb$/,"")
  end
  
  define_callbacks :authenticate
  
  class_attribute :authorization_hash
  
  class << self
        
    # Authorize a list of actions by a certain right
    #
    # ==== Parameters
    # action<Array[Symbol]> :: List of actions, if empty applies to all actions.
    # 
    # ==== Options
    # :by :: The right to check [required]
    # 
    # ==== Returns
    # false/true :: Will redirect :back and log an [AUTH] error
    #--
    def authorize(*actions)
      options = actions.extract_options!
      raise ArgumentError, "You must specify the :by option" if !options.has_key?(:by)
      authorizations = self.authorization_hash || {}
      if actions.any?
        actions.each do |a|
          authorizations[a] ||= [] 
          authorizations[a] << options[:by]
        end
      else
        authorizations[:*] ||= []
        authorizations[:*] << options[:by]        
      end
      self.authorization_hash = authorizations
    end
    
    def authorizations
      self.authorization_hash || {}
    end
    
  end

  protected

  # Sets locale according to the configuration on every request
  def set_locale
    I18n.locale = Skyline::Configuration.locale.present? ? Skyline::Configuration.locale : "en-US"
  end
  
  def default_url_options(options={})
    return {} if options.blank?
    if options[:id].andand.kind_of?(Skyline::Article)
      {:type => options[:id].class}
    elsif options[:article_id].andand.kind_of?(Skyline::Article)
      {:article_type => options[:article_id].class}
    end
  end
  
  # Returns the currently logged in user
  # --
  def current_user
    (self.respond_to?(:skyline_current_user) ? self.skyline_current_user : nil) || @current_user
  end  
  
  helper_method :current_user  
  
  def current_user=(c)
    @current_user = c
  end
  
  # Override this in the controller, all actions are protected by default
  def protect?; true; end
      
  # Authenticate the user
  def authenticate_user
    if self.protect? 
      run_callbacks :authenticate do
        self.current_user = Skyline::Configuration.user_class.find_by_identification(session[:skyline_user_identification]) if !self.current_user && session[:skyline_user_identification]
        unless self.current_user
          # Store location to go back to in session...
          session[:before_login_url] = request.fullpath
          return redirect_to(new_skyline_authentication_path)
        end
      end
    end
  end
  
  # Handle the user preferences
  # --
  def handle_user_preferences
    if cookies["skyline_up"].present?
      up = ActiveSupport::JSON.decode(cookies["skyline_up"])
      
      up.each do |k,v|
        if k == "_delete"
          v.each do |delete_id|
            current_user.user_preferences.remove_key(delete_id)
          end
        else
          current_user.user_preferences.set(k,v)
        end
      end
      
      cookies.delete("skyline_up")
    end 
  end
  
  # The authorization callback
  # --
  def authorize_user_for_action    
    authorizations = self.class.authorizations[self.action_name.to_sym] || self.class.authorizations[:*]        
    if authorizations && authorizations.any?
      success = authorizations.find do |r| 
        if r.respond_to?(:call)
          r.call(current_user,self,self.action_name.to_sym)
        else
          current_user.allow?(r)
        end
      end
      
      handle_unauthorized_user unless success
    end
  end
    
  # Authorize a user within an action.
  # This is used if you only know whiting the action if you should continue or not.
  # Usage is something like:
  #   
  #   return unless authorize_user(:newsletter_destroy,@newsletter)     
  #
  # ==== Parameters
  # right<Symbol>:: The right to check
  #
  # ==== Returns
  # Boolean:: If true is returned the user is allowed to continue on false handle_unauthorized_user is
  #           called, this will render a page with :status => :unauthorized
  # --
  def authorize_user(right)
    if current_user.allow?(right) 
      return true
    else
      handle_unauthorized_user
      return false
    end 
  end
  
  # Handle an unauthorized user
  # Currently just logs an [AUTH] message and renders an UNAUTHORIZED text on the screen
  # --
  def handle_unauthorized_user
    logger.warn("[AUTH] Unauthorized access to #{self.controller_name}/#{self.action_name} by #{current_user.email} (ID=#{current_user.id})")
    render(:text => "UNAUTHORIZED", :status => :unauthorized)    
  end
       
  # Set the current menu item
  #
  # ==== Parameters
  # menuitem<Symbol> :: The ID/Symbol of the current menu item in the submenu defined by 
  #  the submenu method.
  #--
  def current_menu_item=(menuitem)
    @_menuitem = menuitem    
  end
  def current_menu_item
    @_menuitem || self.class.default_menu
  end
  helper_method :current_menu_item
  
  # A shortcut for messages store
  # Messages work just like Flashes, so you can do
  # messages.now[:error] and messages[:error]
  #--
  def messages
    unless defined? @_messages
      @_messages = session["_messages"] ||= ActionDispatch::Flash::FlashHash.new
      @_messages.sweep
    end
    @_messages
  end
  helper_method :messages
    
  # A shortcut for notifications store
  # Notifications work just like Flashes, so you can do
  # notifications.now[:error] and notifications[:error]
  #
  # The difference between messages and notifications are that
  # notifications should be rendered as volatile, they should
  # dissapear after some time from the GUI.
  #--
  def notifications
    unless defined? @_notifications
      @_notifications = session["_notifications"] ||= ActionDispatch::Flash::FlashHash.new
      @_notifications.sweep
    end
    @_notifications
  end
  helper_method :notifications
  
  # Overwrite default rails methods so we correctly reset all messages
  #--
  def perform_action
    super
    self.remove_volatile_variables!
  end

  # Overwrite default rails methods so we correctly reset all messages
  #--  
  def reset_session
    super
    self.remove_volatile_variables!    
  end
  
  # Remove @_messages and @_notifications
  #--
  def remove_volatile_variables!
    remove_instance_variable(:@_messages) if defined? @_messages
    remove_instance_variable(:@_notifications) if defined? @_notifications
  end
  
  
  def stack
    return @stack if @stack
    types = params[:types].kind_of?(String) ? params[:types].split("/") : params[:types]
    @stack ||= Skyline::Content::Stack.new(@implementation, types || [])
    @class = @stack.klass
  
    logger.debug "STACK classes: " + @stack.collect{|s| s.class}.inspect    
    logger.debug "STACK: " + @stack.inspect      
    @stack
  end
  helper_method :stack


  # object_url obj,:action => "edit"
  # use options[:ancestor] to go levels up
  # use options[:sub] to add something to the types array
  def object_url(obj,options={})
    ancestor = options.delete(:ancestor).to_i
    
    # Do some type conversion on the params
    types = stack.types.flatten.compact
    
    # 1. Direct hit on stack
    if idx = stack.index(obj)
      types = stack.types[0..(idx-ancestor)].flatten.compact
      logger.debug("OBJECT_URL :: <#{obj.class}, #{obj.id}> :: matched on 1 (#{types.inspect})")
      
    # 2. Direct hit on class of stack.last so we just add the last item to the types array
    elsif stack.last.class == obj.class && stack.last.new_record?
      types << obj.id
      logger.debug("OBJECT_URL :: <#{obj.class}, #{obj.id}> :: matched on 2 (#{types.inspect})")

    # 3. Some other object -> for in main menu group
    elsif obj.kind_of? ActiveRecord::Base
      types = [obj.class.to_s.demodulize.pluralize.underscore,obj.id]
      logger.debug("OBJECT_URL :: <#{obj.class}, #{obj.id}> :: matched on 3 (#{types.inspect})")
      
    # 4. Some other class -> for in main menu [DOC]
    elsif obj.kind_of? Class
      types = [obj.to_s.demodulize.pluralize.underscore]
      logger.debug("OBJECT_URL :: <class=#{obj}> :: matched on 4 (#{types.inspect})")
    end
    
    types << options.delete(:sub) if options.has_key? :sub
        
    url_for options.update(:types => types)
  end
  helper_method :object_url
    
    
  def javascript_redirect_to(url)
    render :js => "window.location = '#{url.to_s.html_safe}';"
  end 
  
end
