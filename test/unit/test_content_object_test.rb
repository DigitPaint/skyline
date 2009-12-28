require 'test_helper'
require 'mocks/test_content_object.rb'

class TestContentObjectTest < ActiveSupport::TestCase
  context "test content object" do
    setup do
      upload = ActionController::TestUploadedFile.new((Skyline.root + "db/fixtures/files/test.gif").to_s, "image/gif")
      @image = Skyline::MediaFile.new(:name => "test_img.gif", :parent_id => nil, :data => upload)
      @image.save
    end
    should "be able to save without an image" do
      test_content_object = Skyline::TestContentObject.new
      test_content_object.header = "Test"
      
      test_content_object.save      
      assert !test_content_object.new_record?
    end
    
    should "create an object_ref when an image is linked" do
      test_content_object = Skyline::TestContentObject.new
      
      test_content_object.image = @image
      test_content_object.save
      
      ref = Skyline::ObjectRef.find_by_id(test_content_object.image_id)
      
      assert_valid ref
    end
    
    should "remove object_ref on destroy" do
      test_content_object = Skyline::TestContentObject.new
      
      test_content_object.image = @image
      test_content_object.save
      
      old_image_id = test_content_object.image_id
      
      test_content_object.destroy
      
      ref = Skyline::ObjectRef.find_by_id(old_image_id)      
      assert ref.nil?
    end
    
    should "destroy the ObjectRef with image.destroy" do
      test_content_object = Skyline::TestContentObject.new
      
      test_content_object.image = @image
      test_content_object.save
            
      old_image_id = test_content_object.image_id
      
      test_content_object.image.destroy
      
      ref = Skyline::ObjectRef.find_by_id(old_image_id)
      assert ref.nil?
      
    end
    
    should "be able to call image.dimension" do
      test_content_object = Skyline::TestContentObject.new
      
      test_content_object.image = @image
      assert test_content_object.save
            
      assert test_content_object.image.dimension.inspect            
    end
    
  end
end
