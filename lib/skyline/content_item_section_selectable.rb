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
#      named_scope :for_content_item_section, :conditions => {:published => true}
#      -- else
#      named_scope :for_content_item_section, {}
#    end


module Skyline::ContentItemSectionSelectable
  def self.included(base)
    Skyline::Sections::ContentItemSection.register_selectable_model(base)
    
    if base.column_names.include?("published")
      base.send :named_scope, :for_content_item_section, :conditions => {:published => true}
    else
      base.send :named_scope, :for_content_item_section, {}
    end
  end
end
