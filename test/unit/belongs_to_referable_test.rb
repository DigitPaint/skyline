require 'test_helper'

class Skyline::ReferableTestContentObject < ActiveRecord::Base
  include Skyline::BelongsToReferable
  
  self.table_name = "test_content_objects"
  
  belongs_to_referable :image
end

class Skyline::SpecifiedTestContentObject < ActiveRecord::Base
  include Skyline::BelongsToReferable
  
  self.table_name = "test_content_objects"
  
  belongs_to_referable :image, :allow_protocols => ['http']
end

class Skyline::NilTestContentObject < ActiveRecord::Base
  include Skyline::BelongsToReferable
  
  self.table_name = "test_content_objects"
  
  belongs_to_referable :image, :allow_protocols => nil
end


class TestContentObjectTest < ActiveSupport::TestCase
  
  context "test content object with belongs_to_referable" do
    
    context "with default allow_protocols" do
      # When allow_protocols is not specified, only referable_uris with the default
      # set of allowed protocols should be added (['http', 'https', 'mailto', :relative])
      # See referable_uri_test for tests covering allowed and disallowed protocols
      should "add allowed links with http://" do
        uri = 'http://www.skylinecms.nl'
        
        test_content_object = Skyline::ReferableTestContentObject.new
        
        test_content_object.image = Skyline::ReferableUri.new
        test_content_object.image.uri = uri
        
        assert test_content_object.save
        assert_equal test_content_object.image.uri, uri
      end
      
      should "add allowed links with https://" do
        uri = 'https://www.skylinecms.nl'
        
        test_content_object = Skyline::ReferableTestContentObject.new
        
        test_content_object.image = Skyline::ReferableUri.new
        test_content_object.image.uri = uri
        
        assert test_content_object.save
        assert_equal test_content_object.image.uri, uri
      end
      
      should "not add disallowed links" do
        uri = "javascript:alert('test');"
        
        test_content_object = Skyline::ReferableTestContentObject.new
        
        test_content_object.image = Skyline::ReferableUri.new
        test_content_object.image.uri = uri
        
        assert test_content_object.save
        assert_equal test_content_object.image.uri, ""
      end
    end
    
    context "with custom allow_protocols" do
      # When allow_protocols is specified, only referable_uris with the specified
      # set of allowed protocols should be added (['http'] in this case)
      # See referable_uri_test for tests covering allowed and disallowed protocols
      should "add allowed links" do
        uri = 'http://www.skylinecms.nl'
        
        test_content_object = Skyline::SpecifiedTestContentObject.new
        
        test_content_object.image = Skyline::ReferableUri.new
        test_content_object.image.uri = uri
        
        assert test_content_object.save
        assert_equal test_content_object.image.uri, uri
      end
      
      should "not add disallowed links with https://" do
        uri = "https://www.skylinecms.nl"
        
        test_content_object = Skyline::SpecifiedTestContentObject.new
        
        test_content_object.image = Skyline::ReferableUri.new
        test_content_object.image.uri = uri
        
        assert test_content_object.save
        assert_equal test_content_object.image.uri, ""
      end
      
      should "not add disallowed links with javascript:" do
        uri = "javascript:alert('test');"
        
        test_content_object = Skyline::SpecifiedTestContentObject.new
        
        test_content_object.image = Skyline::ReferableUri.new
        test_content_object.image.uri = uri
        
        assert test_content_object.save
        assert_equal test_content_object.image.uri, ""
      end
    end
    
    context "with no allow_protocols" do
      # When allow_protocols is set to nil, all links whould be added
      # See referable_uri_test for tests covering allowed and disallowed protocols
      should "add links with http" do
        uri = 'http://www.skylinecms.nl'
        
        nil_test_content_object = Skyline::NilTestContentObject.new
        
        nil_test_content_object.image = Skyline::ReferableUri.new
        nil_test_content_object.image.uri = uri
        
        assert nil_test_content_object.save
        assert_equal nil_test_content_object.image.uri, uri
      end
      
      should "add links with https://" do
        uri = "https://www.skylinecms.nl"
        
        nil_test_content_object = Skyline::NilTestContentObject.new
        
        nil_test_content_object.image = Skyline::ReferableUri.new
        nil_test_content_object.image.uri = uri
        
        assert nil_test_content_object.save
        assert_equal nil_test_content_object.image.uri, uri
      end
      
      should "add normally disallowed links with javascript:" do
        uri = "javascript:alert('test');"
        
        nil_test_content_object = Skyline::NilTestContentObject.new
        
        nil_test_content_object.image = Skyline::ReferableUri.new
        nil_test_content_object.image.uri = uri
        
        assert nil_test_content_object.save
        assert_equal nil_test_content_object.image.uri, uri
      end
    end
    
  end
  
end
