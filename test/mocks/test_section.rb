class Skyline::TestSection < ActiveRecord::Base
  include Skyline::SectionItem
  include Skyline::Referable
  
  referable_field :body_a
  referable_field :body_b
  
  attr_accessor :fail_validation
  
  validate :validate_fail_validation
  
  self.table_name = "skyline_test_sections"
  
  protected
  
  def validate_fail_validation
    self.errors.add_to_base("FAILED!!") if self.fail_validation == true
  end
  
    
end

