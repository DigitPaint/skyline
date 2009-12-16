require 'fileutils'

# @private
class Skyline::Sections::RssSection < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  extend Skyline::UrlValidation  
  include Skyline::SectionItem

  
  validates_numericality_of :show_count
  validates_format_of_url :url, :schemes => %w{http}
  
  cattr_accessor :cache_path
  @@cache_path ||= Skyline::Configuration.rss_section_cache_path  

  cattr_accessor :cache_timeout
  @@cache_timeout ||= Skyline::Configuration.rss_section_cache_timeout
  
  after_update :delete_from_cache
  after_destroy :delete_from_cache

  def title
    self.rss_feed ? self.rss_feed[:title] : ""
  end      

  def items
    self.rss_feed ? self.rss_feed[:items] : []
  end
  
  protected
  def cache_file
    File.join(self.class.cache_path, "#{self.id}.yml")
  end
  memoize :cache_file
    
  def rss_feed
    if File.exists?(self.cache_file) && File.mtime(self.cache_file) > Time.now - self.cache_timeout
      YAML.load(File.read(self.cache_file))
    else
      if feed = fetch_feed
        results = RSS::Parser.parse(feed, false)
        channel = results.channel
        feed = {
          :title => channel.title,
          :description => channel.description, 
          :copyright => channel.copyright,
          :category => channel.category.andand.content,
          :date => channel.date,
          :items => []
        }
        results.items.each_with_index do |item, i|
          feed[:items] << {
            :title => item.title, 
            :link => item.link, 
            :author => item.author, 
            :description => item.description, 
            :guid => item.guid, 
            :pubDate => item.pubDate,
            :source => item.source,                        
            :category => item.category.andand.content
          } if i < self.show_count  
        end        
        cache(feed)
        feed
      elsif File.exists?(self.cache_file)
        self.reset_mtime
        YAML.load(File.read(self.cache_file))
      else
        false
      end
    end
#  rescue
#    logger.error "[RssSection] Failed to parse feed!"
#    false
  end
  memoize :rss_feed
  
  def fetch_feed
    logger.debug "[RssSection] Fetching feed #{self.url}"
    feed = open(self.url).read
  rescue
    logger.error "[RssSection] Failed to fetch!"
    false
  end
  
  def cache(feed)
    File.open(self.cache_file, "w") do |f|
      f.write feed.to_yaml
    end
  end
  
  def reset_mtime
    FileUtils.touch(self.cache_file)
  rescue
  end
  
  def delete_from_cache
    File.delete(self.cache_file)
  rescue
  end
end
