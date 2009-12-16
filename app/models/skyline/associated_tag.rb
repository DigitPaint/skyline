# @private
class Skyline::AssociatedTag < ActiveRecord::Base
  set_table_name :skyline_associated_tags
  
  belongs_to :taggable, :polymorphic => true
  belongs_to :tag
  
  after_save :delete_unused_tags
  after_destroy :delete_unused_tags
  
  protected
  def delete_unused_tags
    Skyline::Tag.delete_unused_tags
  end
end