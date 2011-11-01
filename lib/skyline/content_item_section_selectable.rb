# Use this Module in all classes you want to be found in the ContentItemSection
#
#
# Usage: 
# class Model < ActiveRecord::Base
#   include Skyline::ContentItemSectionSelectable
# end
#
# 
# 1) Registers your model in the Skyline::Sections::ContentItemSection.selectable_models list
# 
# 2) Gives your Model the following interface:
# 
#    class  Model < ActiveRecord::Base
#      -- If the model has a 'published' column:
#      scope :for_content_item_section, :conditions => {:published => true}
#      -- else
#      scope :for_content_item_section, {}
#    end


module Skyline::ContentItemSectionSelectable
  def self.included(base)
    Skyline::Sections::ContentItemSection.register_selectable_model(base)
    
    if base.column_names.include?("published")
      base.send :scope, :for_content_item_section, :conditions => {:published => true}
    else
      base.send :scope, :for_content_item_section, {}
    end
  end
end
