class Skyline::RefObject < ActiveRecord::Base
  belongs_to :referable, :polymorphic => true, :autosave => true

  set_table_name :skyline_ref_objects
  
  serialize :options  
  
  validates_presence_of :referable_type
end
