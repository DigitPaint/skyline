# @private
class Skyline::MediaCache < ActiveRecord::Base    
  set_table_name :skyline_media_cache  
  cattr_accessor :cache_path
  @@cache_path ||= Skyline::Configuration.media_file_cache_path
    
  after_destroy :expire_cache
    
  class << self
    def delete_file(path)
      if File.file?(path)
        File.delete(path)
        dir = File.basename(path)
        if File.directory?(dir) && Dir.entries(dir).size == 2
          Dir.delete(dir) rescue nil
        end
      else
        logger.error "Could not sweep #{path}"
      end      
    end            
    
  end
  
  private

  def expire_cache
    # It'd be better to call expire_page here, except it's a
    # controller method and we can't get to it.
    path = self.class.cache_path + "#{self.url}"

    logger.info "Sweeping #{path}"
    delete_file(path)
  end

  def delete_file(path)
    self.class.delete_file(path)
  end
  
end