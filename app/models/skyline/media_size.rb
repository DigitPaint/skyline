class Skyline::MediaSize < ActiveRecord::Base
  self.table_name = "skyline_media_sizes"
  
  belongs_to :media_file
  
  attr_accessible :width, :height
end