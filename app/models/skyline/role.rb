# @private
class Skyline::Role < ActiveRecord::Base
  self.table_name = "skyline_roles"
  
  has_many :grants, :class_name => "Skyline::Grant"
  has_many :users, :class_name => "Skyline::User", :through => :grants
  
  has_and_belongs_to_many :rights, :class_name => "Skyline::Right", :join_table => "skyline_rights_skyline_roles"
end
