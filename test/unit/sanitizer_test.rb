require 'test_helper'
require 'mocks/test_section.rb'

class SanitizerTest < ActiveSupport::TestCase
  
  context "The Skyline::Sanitizer module" do
    
    should "remove disallowed tags with default settings" do
      html = "<script>alert('scripttext only')</script>"
      ts = Skyline::TestSection.new(:body_a => html)
      
      assert ts.save
      assert_equal ts.body_a.strip, "alert('scripttext only')"
    end
    
    should "not remove allowed tags" do
      html = "<p>small testparagraph with <strong>strong</strong> part</p>"
      ts = Skyline::TestSection.new(:body_a => html)
      
      assert ts.save
      assert_equal ts.body_a.strip, html
    end
    
    should "remove disallowed tags while keeping allowed tags with default settings" do
      html = "<p>small testparagraph with <script>alert('scripttext')</script> part</p>"
      ts = Skyline::TestSection.new(:body_a => html)
      
      assert ts.save
      assert_equal ts.body_a.strip, "<p>small testparagraph with alert('scripttext') part</p>"
    end
    
    should "remove disallowed attributes with default settings" do
      html = "<p onclick=\"alert('hoi')\">small testparagraph</p>"
      ts = Skyline::TestSection.new(:body_a => html)
      
      assert ts.save
      assert_equal ts.body_a.strip, "<p>small testparagraph</p>"
    end
    
    should "keep skyline attributes with default settings" do
      html = "<p data-skyline-referable-type=\"LinkRef\" data-skyline-referable-id=\"1\">small testparagraph</p>"
      ts = Skyline::TestSection.new(:body_a => html)
      
      assert ts.save
      assert_equal ts.body_a.strip, html
    end
    
    should "allow relative links with default settings" do
      html = "<a href=\"home.html\">Go Home</a>"
      ts = Skyline::TestSection.new(:body_a => html)
      
      assert ts.save
      assert_equal ts.body_a.strip, html
    end
    
    should "disallow links to unsupported protocols with default settings" do
      html = "<a href=\"smb://server\">To Server</a>"
      ts = Skyline::TestSection.new(:body_a => html)
      
      assert ts.save
      assert_equal ts.body_a.strip, "<a>To Server</a>"
    end
    
    should "pass sanitizable_fields to children while subclassing" do
      class TSSubclass < Skyline::TestSection
        
      end
      
      html = "<p>small testparagraph with <script>alert('scripttext')</script> part</p>"
      ts = TSSubclass.new(:body_a => html)
    
      assert ts.save
      assert_equal ts.body_a.strip, "<p>small testparagraph with alert('scripttext') part</p>"
    end
    
    should "allow cancellation" do
      class TSCancel < Skyline::TestSection
        has_sanitizable_fields :body_a, false
      end
      
      html = "<p>small testparagraph with <script>alert('scripttext')</script> part</p>"
      ts = TSCancel.new(:body_a => html)
    
      assert ts.save
      assert_equal ts.body_a, html
    end
    
    should "remove all html when requested" do
      class TSRemove < Skyline::TestSection
        has_sanitizable_fields :body_a, :sanitize => :all
      end
        
      html = "<p>small testparagraph with <strong>strong</strong> part</p>"
      ts = TSRemove.new(:body_a => html)
      
      assert ts.save
      assert_equal ts.body_a.strip, "small testparagraph with strong part"
    end
    
    should "have configureable elements for individual fields" do
      class TSElement < Skyline::TestSection
        has_sanitizable_fields :body_a, :sanitize => {:elements => ['p']}
        has_sanitizable_fields :body_b, :sanitize => {:elements => ['strong']}
      end
    
      html = "<p>small testparagraph with <strong>strong</strong> part</p>"
      ts = TSElement.new(:body_a => html, :body_b => html)
      
      assert ts.save
      assert ts.body_a.strip == "<p>small testparagraph with strong part</p>"
      assert ts.body_b.strip == "small testparagraph with <strong>strong</strong> part"
    end
    
    should "have configureable attributes for all elements" do
      class TSAttributes < Skyline::TestSection
        has_sanitizable_fields :body_b, :sanitize => {:elements => ['p', 'strong', 'span'], :attributes => {:all => ['class']}}
      end
    
      html = "<p class=\"testclass\" id=\"testid\">small testparagraph with <span class=\"testclass\" id=\"testid\">spanned</span> part</p>"
      ts = TSAttributes.new(:body_a => html, :body_b => html)
      
      assert ts.save
      assert_equal ts.body_a.strip, html
      assert_equal ts.body_b.strip, "<p class=\"testclass\">small testparagraph with <span class=\"testclass\">spanned</span> part</p>"
    end
    
    should "have configureable attributes for selected elements" do
      class TSAttributesConfig < Skyline::TestSection
        has_sanitizable_fields :body_b, :sanitize => {:elements => ['p', 'strong', 'span'], :attributes => {'p' => ['id'], 'span' => ['class']}}
      end
      
      html = "<p class=\"testclass\" id=\"testid\">small testparagraph with <span class=\"testclass\" id=\"testid\">spanned</span> part</p>"
      ts = TSAttributesConfig.new(:body_a => html, :body_b => html)
      
      assert ts.save
      assert_equal ts.body_a.strip, html
      assert_equal ts.body_b.strip, "<p id=\"testid\">small testparagraph with <span class=\"testclass\">spanned</span> part</p>"
    end
    
    should "have configurable settings for valid protocols" do
      class TSProtocol < Skyline::TestSection
        has_sanitizable_fields :body_a, :sanitize => {:elements => ['a'], :attributes => {'a' => ['href']}, :protocols => {'a' => {'href' => ['http']}}}
        has_sanitizable_fields :body_b, :sanitize => {:elements => ['a'], :attributes => {'a' => ['href']}, :protocols => {'a' => {'href' => ['ftp']}}}
      end
      
      html = "<a href=\"ftp://server\">Server</a>"
      ts = TSProtocol.new(:body_a => html, :body_b => html)

      assert ts.save
      assert_equal ts.body_a.strip, "<a>Server</a>"
      assert_equal ts.body_b.strip, html
    end
    
    should "be able to filter relative links" do
      class TSRelative < Skyline::TestSection
        has_sanitizable_fields :body_a, :sanitize => {:elements => ['a'], :attributes => {'a' => ['href']}, :protocols => {'a' => {'href' => ['http']}}}
        has_sanitizable_fields :body_b, :sanitize => {:elements => ['a'], :attributes => {'a' => ['href']}, :protocols => {'a' => {'href' => ['http', :relative]}}}
      end
      
      html = "<a href=\"/index.html\">Index</a>"
      ts = TSRelative.new(:body_a => html, :body_b => html)

      assert ts.save
      assert_equal ts.body_a.strip, "<a>Index</a>"
      assert_equal ts.body_b.strip, html
    end
    
    should "allow access and updates to the default configuration" do
      class TSRelative < Skyline::TestSection
        has_sanitizable_fields :body_b, :sanitize => Skyline::Sanitizer.default_config.merge(:elements => Skyline::Sanitizer.default_config[:elements] << 'script')
      end
      
      html = "<p>small testparagraph with <script>alert('scripttext')</script> part</p>"
      ts = TSRelative.new(:body_a => html, :body_b => html)

      assert ts.save
      assert_equal ts.body_a.strip, "<p>small testparagraph with alert('scripttext') part</p>"
      assert_equal ts.body_b.strip, html
    end
    
    should "be able to remove content of removed tags" do
      class TSRelative < Skyline::TestSection
        has_sanitizable_fields :body_a, :sanitize => Skyline::Sanitizer.default_config.merge(:remove_contents => true)
      end
      
      html = "<p>small testparagraph with <script>alert('scripttext')</script> part</p>"
      ts = TSRelative.new(:body_a => html)

      assert ts.save
      assert_equal ts.body_a.strip, "<p>small testparagraph with  part</p>"
    end
    
    should "allow specfication of removable content on a per-tag basis" do
      class TSRelative < Skyline::TestSection
        has_sanitizable_fields :body_a, :sanitize => Skyline::Sanitizer.default_config.merge(:remove_contents => true)
        has_sanitizable_fields :body_b, :sanitize => Skyline::Sanitizer.default_config.merge(:remove_contents => ['script'])
      end
      
      html = "<p>small testparagraph with <script>alert('scripttext')</script> part and <font>font</font> part</p>"
      ts = TSRelative.new(:body_a => html, :body_b => html)

      assert ts.save
      assert_equal ts.body_a.strip, "<p>small testparagraph with  part and  part</p>"
      assert_equal ts.body_b.strip, "<p>small testparagraph with  part and font part</p>"
    end
    
  end
  
end