class Skyline::TestContentObject < ActiveRecord::Base
  include Skyline::BelongsToReferable
   
  belongs_to_referable :image
    
  # before_save :create_object_ref
  # after_save :update_object_ref
  # 
  # belongs_to :image, :class_name => "Skyline::ObjectRef", :foreign_key => :image_id, :dependent => :destroy
  # 
  # def image=(image)
  #   @image = image
  # end
  # 
  # private
  # def create_object_ref
  #   unless @image.nil?
  #     @object_ref = Skyline::ObjectRef.find_or_create_by_id(self.image_id)
  #     @object_ref.update_attributes(
  #                         :referable_id =>@image.id,
  #                         :referable_type =>@image.class.name,
  #                         :refering_type =>self.class.name,
  #                         :refering_column_name =>"image_id")
  #     self.image_id = @object_ref.id if self.image_id.nil?
  #     self.image = @object_ref
  #   end    
  # end
  # 
  # def update_object_ref
  #   Skyline::ObjectRef.update_all({:refering_id => self.id}, "id = #{@object_ref.id}") unless @object_ref.blank?
  # end
end
