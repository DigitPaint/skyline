require 'test_helper'

class ReferableUriTest < ActiveSupport::TestCase
  
  context "ReferableUri class cleaning URI" do
    
    # URI cleaning: ensuring only URIs with allowed protocols are stored
    # Activated by setting referable_uri.allow_protocols
    #
    # This is built-in in BelongsToReferable and activated by specifying:
    # belongs_to_referable, :allow_protocols => ['http', 'mailto']
    # See BelongsToReferableTest for further usage examples
    #
    # Note: encoded URIs below decode to "javascript:alert('test');"
    
    referable_uri = Skyline::ReferableUri.new
    referable_uri.allow_protocols = ['http', 'https', 'mailto', :relative]
    
    should "allow allowed protocols" do
      uri = "http://www.skylinecms.nl"
      
      referable_uri.uri = uri
      referable_uri.save
      assert_equal uri, referable_uri.uri
    end
    
    should "add relative links" do
      uri = "/images/test.png"
      
      referable_uri.uri = uri
      referable_uri.save
      assert_equal uri, referable_uri.uri
    end
    
    should "not add relative links when they are not allowed" do
      uri = "/images/test.png"
      
      not_relative_referable_uri = Skyline::ReferableUri.new
      not_relative_referable_uri.allow_protocols = ['http', 'https', 'mailto']
      
      not_relative_referable_uri.uri = uri
      not_relative_referable_uri.save
      assert_equal not_relative_referable_uri.uri, ""
    end
    
    should "remove disallowed protocols" do
      uri = "javascript:alert('test');"
      
      referable_uri.uri = uri
      referable_uri.save
      assert_equal referable_uri.uri, ""
    end
    
    should "remove disallowed protocols with 0-bytes inserted" do
      uri = "java\0script:alert('test');"
      
      referable_uri.uri = uri
      referable_uri.save
      assert_equal referable_uri.uri, ""
    end
    
    should "remove disallowed protocols encapsulated in `" do
      uri = "`javascript:alert('test')`"
      
      referable_uri.uri = uri
      referable_uri.save
      assert_equal referable_uri.uri, ""
    end
    
    should "remove disallowed protocols with hex encoding" do
      uri = "%6A%61%76%61%73%63%72%69%70%74%3A%61%6C%65%72%74%28%27%74%65%73%74%27%29%3B"
      
      referable_uri.uri = uri
      referable_uri.save
      assert_equal referable_uri.uri, ""
    end
    
    should "remove disallowed protocols with html encoding" do
      uri = "&#x6A;&#x61;&#x76;&#x61;&#x73;&#x63;&#x72;&#x69;&#x70;&#x74;&#x3A;&#x61;&#x6C;&#x65;&#x72;&#x74;&#x28;&#x27;&#x74;&#x65;&#x73;&#x74;&#x27;&#x29;&#x3B;"
      
      referable_uri.uri = uri
      referable_uri.save
      assert_equal referable_uri.uri, ""
    end
    
  end
end