# @private
class Skyline::Grant < ActiveRecord::Base
  set_table_name :skyline_grants
  
  belongs_to :user, :class_name => "Skyline::User"
  belongs_to :role, :class_name => "Skyline::Role"
end
