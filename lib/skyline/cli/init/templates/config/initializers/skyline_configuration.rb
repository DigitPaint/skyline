Skyline::Configuration.configure do |config|  
  config.assets_path = File.join(Rails.root,"tmp/upload")
  config.media_file_cache_path = File.join(Rails.root,"tmp/cache/media_files/cache")
  config.rss_section_cache_path = File.join(Rails.root,"tmp/cache/rss_sections/cache")
end