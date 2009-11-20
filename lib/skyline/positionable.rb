# Use this Module in all classes with a position field you want to automatically fill out
#
#
# Usage: 
# class Model < ActiveRecord::Base
#   include Skyline::Positionable
#   self.positionable_scope = :page_id   (Optional)
# end

module Skyline::Positionable
  def self.included(base)
    base.extend(ClassMethods)
    base.send :before_save, :set_position
  end
  
  module ClassMethods
    def positionable_scope
      @positionable_scope
    end
    
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