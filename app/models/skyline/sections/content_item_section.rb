class Skyline::Sections::ContentItemSection < ActiveRecord::Base
  include Skyline::SectionItem

  belongs_to :content_item, :polymorphic => true
  
  validates_presence_of :content_item_type, :content_item_id

  cattr_accessor :selectable_models  
  
  class << self
    def selectable_content_models
      # lazy load all models in /app/models (not recursive) to find all Content models
      Dir.chdir(File.join(Rails.root, "app", "models")) do 
        Dir.glob("*.rb").map{|f| f.sub(".rb","").camelcase.constantize}
      end
      Rails.logger.info "Selectable models for ContentItemSections: " + Skyline::Sections::ContentItemSection.selectable_models.inspect
      selectable_models || []
    end
    
    def register_selectable_model(klass)
      self.selectable_models ||= []
      self.selectable_models.delete_if{|c| c.to_s == klass.to_s } # Hack to remove stale object
      self.selectable_models << klass
    end
    
  end  
end
