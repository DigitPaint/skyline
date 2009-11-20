class Skyline::Tag < ActiveRecord::Base
  set_table_name :skyline_tags
  
  cattr_accessor :taggable_models

  before_validation :sanitize_tag  
  
  class << self
    def taggable_content_models
      # lazy load all models in /app/models (not recursive) to find all Content models
      Dir.chdir(File.join(Rails.root, "app", "models")) do 
        Dir.glob("*.rb").map{|f| f.sub(".rb","").camelcase.constantize}
      end

      taggable_models.delete_if{|m| m.parents.include?(Skyline) }
    end
    
    def delete_unused_tags
      self.connection.execute("DELETE FROM #{self.table_name} WHERE id NOT IN (SELECT DISTINCT tag_id FROM #{Skyline::AssociatedTag.table_name})")
    end
  end
  
  protected
  
  def sanitize_tag
    self.tag = self.tag.to_s.strip.downcase if self.tag
  end
end