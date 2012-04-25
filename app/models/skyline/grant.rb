# @private
class Skyline::Grant < ActiveRecord::Base
  self.table_name = "skyline_grants"
  
  belongs_to :user, :class_name => "Skyline::User"
  belongs_to :role, :class_name => "Skyline::Role"
  
  attr_accessible :role
end
