# @private
class Skyline::Right < ActiveRecord::Base
  self.table_name = "skyline_rights"
  
  has_and_belongs_to_many :roles, :class_name => "Skyline::Role", :join_table => "skyline_rights_skyline_roles"
end
