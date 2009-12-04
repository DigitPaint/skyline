# Positionable automatically adds the last position number to ActiveRecord models 
# in the `position` column. It only set's the position if it isn't set yet.
# 
# By defining an optional scope the position numbering will only look inside a certain scope.
#
# @example Usage: 
#   class Model < ActiveRecord::Base
#     include Skyline::Positionable
#     self.positionable_scope = :parent_id   # (Optional)
#   end
# 
module Skyline::Positionable
  def self.included(base)
    base.extend(ClassMethods)
    base.send :before_save, :set_position
  end
  
  module ClassMethods
    
    # Get the positionable_scope for this class (uses an instance variable on class level)
    #
    # @return [String,Symbol] The scope to look in
    def positionable_scope
      @positionable_scope
    end
    
    # Set the positionable_sope for this class
    #
    # @param scope [String,Symbol] The scope to use, mostly a column name.
    # @return [String,Symbol] The scope that has just been set.
    def positionable_scope=(scope)
      @positionable_scope = scope
    end
  end
    
  def set_position
    if self.class.positionable_scope
      self.position = self.class.find_by_sql(["SELECT MAX(position) as position FROM #{self.class.table_name} WHERE #{self.class.positionable_scope}=?", self.send(self.class.positionable_scope)]).first["position"].to_i + 1 if self.position.nil?
    else
      self.position = self.class.find_by_sql("SELECT MAX(position) as position FROM #{self.class.table_name}").first["position"].to_i + 1 if self.position.nil?
    end
  end  
end