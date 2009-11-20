require 'test_helper'
require 'mocks/test_section.rb'

class TestSectionTest < ActiveSupport::TestCase
  context "test section" do
    setup do
      @small_image_html = "<img src='henk.jpg' skyline-ref-id='' skyline-referable-id='10'  skyline-referable-type='Skyline::MediaFile' width='200' height='200'/>"
      @small_image_no_refs = "<img src=\"broken.jpg\" height=\"200\" width=\"200\" />"
      
      @small_link_html = "<a href=\"henk.html\" skyline-ref-id=\"\" skyline-referable-id=\"10\"  skyline-referable-type=\"Skyline::MediaFile\" class=\"myLink\">my link</a>"
      @small_link_no_refs = "<a href=\"broken\" class=\"myLink\" >my link</a>"
      
      @big_html = "<div>
                  <a href='henk' skyline-ref-id='' skyline-referable-id='10'  skyline-referable-type='Skyline::MediaFile' class='myLink'>
                   <img src='henk.jpg' skyline-ref-id='' skyline-referable-id='10'  skyline-referable-type='Skyline::MediaFile' width='200' height='200'/>
                   bla <span>henk</span>
                 </a>
                 <img src='peter.jpg' skyline-ref-id='' skyline-referable-id='12'  skyline-referable-type='Skyline::MediaFile' width='200' height='200'/>
               </div>"      
    end
    
    should "convert both body html fields to html with ref tags on save" do
      @test_section = Skyline::TestSection.new(:body_a => @small_image_html, :body_b => @big_html)
      @test_section.save
    
      outp = @test_section[:body_a]
      assert_contains(outp, /\[REF:/)
      
      outp = @test_section[:body_b]
      assert_contains(outp, /\[REF:/)
    end
    
    should "create 4 InlineRef Objects on save with correct refering_id" do
      @test_section = Skyline::TestSection.new(:body_a => @small_image_html, :body_b => @big_html)
      @test_section.save
      
      @image_refs = @test_section.image_refs.all
      @link_refs = @test_section.link_refs.all
      
      number_of_refs = @image_refs.size + @link_refs.size
      assert_equal 4, number_of_refs
    end
     
    should "convert REF tags back to html on calling body_a and body_b" do
      @test_section = Skyline::TestSection.new(:body_a => @small_image_html, :body_b => @small_link_html)
      @test_section.save
      
      assert_equal(@small_image_no_refs, @test_section.body_a)
      assert_equal(@small_link_no_refs, @test_section.body_b)
    end
    
    should "convert REF tags back to html with skyline attributes on calling body_a('edit') and body_b('edit')" do
      @test_section = Skyline::TestSection.new(:body_a => @small_image_html, :body_b => @small_link_html)
      @test_section.save
      
      assert_match(/skyline-ref-id/, @test_section.body_a(true))
      assert_match(/skyline-referable-id/, @test_section.body_a(true))
      assert_match(/skyline-referable-type/, @test_section.body_a(true))
    end
    
     should "remove inline_ref when body_a is changed" do
       @test_section = Skyline::TestSection.new(:body_a => @small_image_html, :body_b => @big_html)
       @test_section.save
           
       @test_section.update_attributes(:body_a => @small_link_html)
       
       @image_refs = @test_section.image_refs.all
       @link_refs = @test_section.link_refs.all
      
       number_of_refs = @image_refs.size + @link_refs.size
       
       assert_equal 4, number_of_refs
     end
    
    should "convert html from [REF:id] tag after MediaFile has been deleted (referable_id = nil)" do
      @test_section = Skyline::TestSection.new(:body_a => @small_image_html, :body_b => @big_html)
      @test_section.save
            
      @ref_object = @test_section.image_refs.find(:first, :conditions => {:refering_column_name => "body_a"})
      @ref_object.referable_id = nil
      @ref_object.save
      assert_equal(@small_image_no_refs, @test_section.body_a)
    end
    
    should "remove ref objects when section is removed" do
      @test_section = Skyline::TestSection.new(:body_a => @small_image_html, :body_b => @big_html)
      @test_section.save
      
      @image_refs = @test_section.image_refs.all
      @link_refs = @test_section.link_refs.all
      
      number_of_refs = @image_refs.size + @link_refs.size
      
      assert_equal 4, number_of_refs
      
      @test_section.destroy
      
      @image_refs = @test_section.image_refs.all
      @link_refs = @test_section.link_refs.all
      
      number_of_refs = @image_refs.size + @link_refs.size
      
      assert_equal 0, number_of_refs
    end
    
    should "remove all ref objects for body_a when body_a is changed to '' " do
      @test_section = Skyline::TestSection.new(:body_a => @small_image_html, :body_b => @small_image_html)
      @test_section.save
      
      @image_refs = @test_section.image_refs.all
      @link_refs = @test_section.link_refs.all
      
      number_of_refs = @image_refs.size + @link_refs.size
      assert_equal 2, number_of_refs
            
      @test_section.update_attributes(:body_a => "")
      
      @image_refs = @test_section.image_refs.all
      @link_refs = @test_section.link_refs.all
      
      number_of_refs = @image_refs.size + @link_refs.size     
      assert_equal 1, number_of_refs
    end
    
    should "return last modification of body_a without the need to save" do
      @test_section = Skyline::TestSection.new(:body_a => @small_image_html, :body_b => @small_image_html)
      @test_section.save
      
      @test_section.body_a = @big_html      
      assert_equal(@big_html, @test_section.body_a)
    end
    
    should "create 4 InlineRef Objects on save with correct refering_id and clone" do
      @test_section = Skyline::TestSection.new(:body_a => @small_image_html, :body_b => @big_html)
      @test_section.save
      
      @cloned_section = @test_section.clone
      @cloned_section.save
           
      @image_refs = @test_section.image_refs.all
      @link_refs = @test_section.link_refs.all
      
      number_of_refs = @image_refs.size + @link_refs.size     
      assert_equal 4, number_of_refs
    end
  end
  
  context "A test section" do
    setup do 
      @html = "bla bla bla <a href='' skyline-referable-id='1' skyline-referable-type='Skyline::MediaFile' >continuïteit</a> bla bla"
      @section = Skyline::TestSection.new(:body_a => @html)
      assert @section.save
      assert_equal 1, @section.link_refs.size
      assert @section[:body_a].match(/\[REF/)
    end
    
    context "being saved with no changes to the body_a content" do
      
      should "not remove the refs for body_a" do
        @section.body_b = "abcdef"
        assert @section.save
        assert_equal 1, @section.link_refs.size
        assert @section[:body_a].match(/\[REF/)        
      end
      
      should "should keep the same refs" do
        refs_before = @section.link_refs
        assert @section.save
        refs_after = @section.link_refs(true) 
        
        assert_equal refs_before,refs_after
      end
    end
    
    context "being saved with invalid data" do
      
      setup do
        @section.fail_validation = true
        assert !@section.save
      end
      
      should "not remove the refs for body_a" do
        assert_equal 1, @section.link_refs.size
        assert @section[:body_a].match(/\[REF/)        
      end
      
    end
  
    context "being saved without the sklyine attributes" do
      setup do
        @html = "bla bla bla <a href='' skyline-referable-id='1' skyline-referable-type='Skyline::MediaFile' >continuïteit</a> bla bla"
        @section = Skyline::TestSection.new(:body_a => @html)
        assert @section.save
        assert_equal 1, @section.link_refs.size
        assert @section[:body_a].match(/\[REF/)      
      end
    
    
      should "should not have any link_refs anymore" do
        @section.reload
        assert !@section.body_a.match(/REF/)
        @section.body_a = @section.body_a
        assert @section.save
        assert_equal 0, @section.link_refs.size        
        assert !@section[:body_a].match(/\[REF/)
      end
    end
    
    context "being cloned" do
      setup do
        @html = "bla bla bla <a href='' skyline-referable-id='1' skyline-referable-type='Skyline::MediaFile' >continuïteit</a> bla bla"
        @section = Skyline::TestSection.new(:body_a => @html)
        assert @section.save
        @section_refs = Skyline::InlineRef.hash_refs_for_object(@section,:body_a)        
        assert_equal 1, @section.link_refs.size
        assert_equal 1, @section_refs.keys.size
        assert @section[:body_a].match(/\[REF/)
        @section = Skyline::TestSection.find(@section.id)
          
        @clone = @section.clone
        assert @clone.save
        @clone_refs = Skyline::InlineRef.hash_refs_for_object(@clone,:body_a)
        assert_equal 1, @clone_refs.keys.size
      end
      
      should "keep it's own refs" do
        assert_equal @section_refs.keys, Skyline::InlineRef.hash_refs_for_object(@section,:body_a).keys
        @section_refs.keys.each do |k|
          assert @section[:body_a].match(/\[REF:#{k}\]/)
        end
      end
      
      should "not share refs with clone" do
        clone_keys = @clone_refs.keys
        @section_refs.keys.each do |k|
          assert !clone_keys.include?(k)
        end
        clone_keys.each do |k|
          assert @clone[:body_a].match(/\[REF:#{k}\]/)
        end
      end
      
      
      
    end
  end
end
