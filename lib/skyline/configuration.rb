# Contains the default skyline configuration. Currently this is also
# the place to look for available configuration options.
#
# @todo This configuration class will someday change as it's not flexible enough
#   for our purposes.
class Skyline::Configuration < Configure
  
  defaults do |config|
    config.name = File.expand_path(Rails.root).split("/").last
    config.title = config.name.humanize
    
    config.sections = {:default => [
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
                         "page_fragment_section"]
                      }
    
    config.articles = []
    config.content_classes = []
    
    config.rss_section_cache_timeout = 1.hour  
    
    config.custom_logo = false
    config.skyline_logo = "/skyline/images/logo.png"
    config.branding_name = ""
    
    config.locale = "en-US"
    
    # ie: [{:path => "/stylesheets/skyline.css", :if => "lte IE 7"}]
    config.custom_stylesheets = []
    
    if Rails.env == "production"
      config.assets_path = nil
      config.media_file_cache_path = nil
      config.rss_section_cache_path = nil
    else
      config.assets_path = File.join(Rails.root,"/tmp/upload")
      config.media_file_cache_path = File.join(Rails.root,"/tmp/media_files/cache")
      config.rss_section_cache_path = File.join(Rails.root,"/tmp/rss_sections/cache")
    end 
    
    unless ActiveSupport::Dependencies.load_once_path?(__FILE__)
      # We need to reload the configuration because this file get's reloaded 
      if (Rails.root + "config/initializers/skyline_configuration.rb").exist?
        load Rails.root + "config/initializers/skyline_configuration.rb"
      end    
    end
    
    # Default URL admin prefix (default = /skyline/...)
    config.url_prefix = "/skyline"
    
    # The skyline_root default route.
    # Most unfortunately we have to set it like this because we cannot override a specific route from the plugin
    # in the implementation.
    config.default_route = {:controller => "articles", :action => "index", :type => "skyline/page"}
    
    # enable/disable 'modules'
    config.enable_pages = true
    config.enable_multiple_variants = true
    config.enable_locking = true
    config.enable_enforce_only_one_user_editing = true
    config.enable_publication_history = true
  end  
  
  def after_configure
    check_or_create_path(self["assets_path"],"assets_path")
    check_or_create_path(self["media_file_cache_path"],"media_file_cache_path")
    check_or_create_path(self["rss_section_cache_path"],"rss_section_cache_path")
    
    Skyline::MediaNode.assets_path = self["assets_path"]  
    Skyline::MediaCache.cache_path = self["media_file_cache_path"]
    Skyline::Sections::RssSection.cache_path = self["rss_section_cache_path"]
    Skyline::Sections::RssSection.cache_timeout = self["rss_section_cache_timeout"]
    
    Skyline::Rendering::Renderer.register_renderables(:sections,self["sections"])
    Skyline::Rendering::Renderer.register_renderables(:articles,self["articles"] + ["Skyline::Page"])      
  end  
  
  def articles
    self["articles"].map(&:constantize)
  end  
  
  def content_classes
    self["content_classes"].map(&:constantize)
  end
  
  def url_prefix
    self["url_prefix"].gsub(/\A\//, "")
  end
  
  protected
    
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