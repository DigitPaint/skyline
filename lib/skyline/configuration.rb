# Contains the default skyline configuration. Currently this is also
# the place to look for available configuration options.
#
# @todo This configuration class will someday change as it's not flexible enough
#   for our purposes.
class Skyline::Configuration < Configure
  
  defaults do |config|
    # The application name (defaults to the name)
    config.name = File.expand_path(Rails.root).split("/").last
    
    # The application title
    config.title = config.name.humanize
    
    # Available sections per article
    config.sections = {
      :default => [
        "wysiwyg_section", 
        "heading_section", 
        "rss_section", 
        "iframe_section",
        "content_collection_section", 
        "content_item_section", 
        "splitter_section", 
        "link_section",
        "raw_section",
        "media_section",
        "redirect_section",
        "page_fragment_section"
      ]
    }
    
    # Available articles (Skyline::Page is always included)
    config.articles = []
    
    # Available content classes
    config.content_classes = []
    
    # Do you want to use a custom logo? If so define it here    
    config.custom_logo = false
    config.skyline_logo = "/skyline/images/logo.png"
    
    # Add a "branding" name so you don't have to use the name "Skyline"
    config.branding_name = ""
    
    # The Skyline locale
    config.locale = "en-US"
    
    # Custom stylesheets to include
    # ie: [{:path => "/stylesheets/skyline.css", :if => "lte IE 7"}]
    config.custom_stylesheets = []
    
    # Default configuration for Sanitizer
    # Only allow these tags => :elements
    # Only allow these attributes for selected tags => :attributes
    # Only allow these protocols in a href attributes => :protocols
    config.default_sanitizer_options = {
      :elements => %w[
        a b br caption col colgroup div em i li
        ol p span strong sub sup table tbody td
        tfoot th thead tr ul img
      ],
      :attributes => {
        :all         => ['dir', 'lang', 'title', 'data-skyline-referable-type',
                          'data-skyline-referable-id', 'data-skyline-ref-id', 'class', 'id'],
        'a'          => ['href', 'target'],
        'col'        => ['span', 'width'],
        'colgroup'   => ['span', 'width'],
        'div'        => ['style'],
        'ol'         => ['start', 'reversed', 'type'],
        'span'       => ['style'],
        'table'      => ['summary', 'width'],
        'td'         => ['abbr', 'axis', 'colspan', 'rowspan', 'width'],
        'th'         => ['abbr', 'axis', 'colspan', 'rowspan', 'scope', 'width'],
        'ul'         => ['type'],
        'img'        => ['src', 'width', 'height', 'alt']
      },
      :protocols => {
        'a'          => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]},
      }
    }
    
    # Path configuration
    if Rails.env == "production"
      config.assets_path = nil
      config.media_file_cache_path = nil
      
      # Only if you need the rss section
      config.rss_section_cache_path = nil
    else
      config.assets_path = Rails.root + "tmp/upload"
      config.media_file_cache_path = Rails.root + "tmp/media_files/cache"
      
      # Only if you need the rss section      
      config.rss_section_cache_path = Rails.root + "tmp/rss_sections/cache"
    end 
        
    # Authentication User model
    config.user_class = Skyline::User
    
    # Number of login attempts allowed by a user before their accounts are locked (if 0, no limit)
    config.login_attempts_allowed = 0
    
    # The skyline_root default route.
    # Most unfortunately we have to set it like this because we cannot override a specific route from the plugin
    # in the implementation.    
    config.default_route = {:to => "articles#index", :type => "skyline/page"}
        
    # enable/disable 'modules'
    config.enable_pages = true
    config.enable_multiple_variants = true
    config.enable_locking = true
    config.enable_enforce_only_one_user_editing = true
    config.enable_publication_history = true
    
    # Section stuff
    config.rss_section_cache_timeout = 1.hour
    
    # We need to reload the configuration if this file get's reloaded 
    unless ActiveSupport::Dependencies.load_once_path?(__FILE__)
      if (Rails.root + "config/skyline.rb").exist?
        load Rails.root + "config/skyline.rb"
      end    
    end
    
    # Use SSL, set a secure cookie only for SSL connections
    config.use_ssl = false
    
    # Stub so the method below works
    config.url_prefix = nil   
  end  
  
  def after_configure
    sanitize_paths
    
    Skyline::MediaNode.assets_path = self["assets_path"]  
    Skyline::MediaCache.cache_path = self["media_file_cache_path"]
    
    if self.sections.values.flatten.uniq.include?("rss_section")
      Skyline::Sections::RssSection.cache_path = self["rss_section_cache_path"]
      Skyline::Sections::RssSection.cache_timeout = self["rss_section_cache_timeout"]
    end
    
    Skyline::Rendering::Renderer.register_renderables(:sections,self["sections"])
    Skyline::Rendering::Renderer.register_renderables(:articles,self["articles"] + ["Skyline::Page"])
    
    Skyline::Engine::SESSION_OPTIONS[:secure] = Skyline::Configuration.use_ssl
  end
  
  def url_prefix
    Skyline::Engine.config.skyline.mounted_engine_path
  end
  
  def articles
    self["articles"].map(&:constantize)
  end  
  
  def content_classes
    self["content_classes"].map(&:constantize)
  end
    
  protected
  
  # Ensures that all paths are Pathname objects
  def sanitize_paths
    %w{assets_path media_file_cache_path}.each do |key|
      self[key] = Pathname.new(self[key]) if self[key] && !self[key].kind_of?(Pathname)
      check_or_create_path(self[key], key)
    end    
  end
    
  # Check if a path is set, and if we're in production made raise an assertion
  # if the path does not exist. It just creates the path in development mode.
  def check_or_create_path(path, key="assets_path")
    raise "#{key} must be set!" if path.blank?
    unless File.directory?(path)
      if Rails.env == "production"
        raise("#{key} \"#{path}\" does not exist") 
      else
        require 'fileutils'
        Rails.logger.warn "Creating #{key} directory in \"#{path}\""
        FileUtils.mkdir_p(path)
      end
    end
  end
end