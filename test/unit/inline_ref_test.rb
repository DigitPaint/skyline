require 'test_helper'
require 'mocks/test_section.rb'

class BogusSection
  def id; @id ||= 10000; end
  
  attr_accessor :body
end

class TestSectionTest < ActiveSupport::TestCase
  
  context "InlineRef class" do
    setup do
      @section = BogusSection.new
    end
    
    context "parsing html" do
            
      should "create new refs" do
        html = "abcdefghi <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' /> <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' />"
        parsed_html, ids = Skyline::InlineRef.parse_html(html,@section,:body)
        assert_equal 2, ids.size
        assert_equal 2,Skyline::InlineRef.count(:conditions => {:refering_id => @section.id, :refering_type => @section.class.name})
        
        assert_equal ids,Skyline::InlineRef.all(ids).map(&:id)
        ids.each do |id|
          assert parsed_html =~ /\[REF:#{id}\]/
        end
      end
      
      should "delete unused refs" do
        html = "abcdefghi <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' /> <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' />"
        parsed_html, ids = Skyline::InlineRef.parse_html(html,@section,:body)
        assert_equal 2, ids.size
        assert_equal 2,Skyline::InlineRef.count(:conditions => {:refering_id => @section.id, :refering_type => @section.class.name})        
        assert_equal ids,Skyline::InlineRef.all(ids).map(&:id)        

        new_html = "abcdefghi <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' />"
        new_parsed_html, new_ids = Skyline::InlineRef.parse_html(new_html,@section,:body)        
        assert_equal 1, new_ids.size
        assert_equal 1,Skyline::InlineRef.count(:conditions => {:refering_id => @section.id, :refering_type => @section.class.name})        
        assert_equal new_ids,Skyline::InlineRef.all(new_ids).map(&:id)
        assert_equal new_ids,Skyline::InlineRef.all(ids).map(&:id)
      end
      
      should "update existing refs" do
        html = "abcdefghi <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' /> bla bla"
        section = Skyline::TestSection.new(:body_a => html)
        assert section.save
        refs_1 = Skyline::InlineRef.all(:conditions => {:refering_id => section.id, :refering_type => section.class.name}).map(&:id)
        section.body_a = section.body_a(true).gsub("skyline-referable-id='1'","skyline-referable-id='2'")
        assert section.save
        refs_2 = Skyline::InlineRef.all(:conditions => {:refering_id => section.id, :refering_type => section.class.name}).map(&:id)

        assert_equal refs_1,refs_2
      end
      
      should "only update it's own refs and replace 'foreign' refs" do
        html = "abcdefghi <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' /> bla bla"
        section_1 = Skyline::TestSection.new(:body_a => html)
        assert section_1.save
        assert_equal 1,Skyline::InlineRef.count(:conditions => {:refering_id => section_1.id, :refering_type => section_1.class.name})
        
        section_2 = Skyline::TestSection.new(:body_a => section_1.body_a(true))
        assert section_2.save
        assert_equal 1,Skyline::InlineRef.count(:conditions => {:refering_id => section_2.id, :refering_type => section_2.class.name})
        assert_equal 1,Skyline::InlineRef.count(:conditions => {:refering_id => section_1.id, :refering_type => section_1.class.name})
        
        assert_not_equal section_1.body_a(true), section_2.body_a(true)
      end
      
      should "make sure that copying a ref from one field to another doesn't break" do
        html = "abcdefghi <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' /> bla bla"
        s1 = Skyline::TestSection.new(:body_a => html)
        assert s1.save
        assert_equal 1,Skyline::InlineRef.count(:conditions => {:refering_id => s1.id, :refering_type => s1.class.name, :refering_column_name => "body_a"})

        s1.body_b = s1.body_a(true)
        assert s1.save
        assert_equal 1,Skyline::InlineRef.count(:conditions => {:refering_id => s1.id, :refering_type => s1.class.name, :refering_column_name => "body_a"})
        assert_equal 1,Skyline::InlineRef.count(:conditions => {:refering_id => s1.id, :refering_type => s1.class.name, :refering_column_name => "body_b"})        
      end
      
    end
    
    context "converting REFS to html" do
      
      setup do
        @html = "a <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' /> <a href='' skyline-referable-id='2' skyline-referable-type='Skyline::Page'>test</a>"
        @parsed_html, @ref_ids = Skyline::InlineRef.parse_html(@html,@section,:body)
        assert_equal 2,Skyline::InlineRef.count(:conditions => {:refering_id => @section.id, :refering_type => @section.class.name})                
      end
      
      should "return all refs on #hash_refs_for_object" do
        refs = Skyline::InlineRef.hash_refs_for_object(@section,:body)
        assert_equal 2,refs.keys.size
      end
      
    end
    
    context "with external links" do 
      
      setup do
        @html = "<a href=\"http://www.google.com\" skyline-referable-type=\"Skyline::ReferableUri\">Link1</a>link1</a> <a href=\"http://www.digitpaint.nl\" skyline-referable-type=\"Skyline::ReferableUri\">link2</a>"
        
      end
      
      should "create a ReferableUri object for each external link" do 
        s1 = Skyline::TestSection.new(:body_a => @html)
        assert s1.save
        
        refs = Skyline::InlineRef.all(:conditions => {:refering_id => s1.id, :refering_type => s1.class.name, :refering_column_name => "body_a"})
        assert_equal 2, refs.size
        referable_uris = refs.map(&:referable)
        uris = referable_uris.map(&:uri)
        
        assert_equal 2,referable_uris.select{|r| r.kind_of?(Skyline::ReferableUri) }.size
        assert_equal ["http://www.google.com", "http://www.digitpaint.nl"], uris
      end
      
      should "not break when recovering from a validation" do
        s1 = Skyline::TestSection.new(:body_a => @html)
        s1.fail_validation = true
        
        assert !s1.save
        assert_equal 0,Skyline::InlineRef.count(:conditions => {:refering_id => s1.id, :refering_type => s1.class.name, :refering_column_name => "body_a"})
        
        s2 = Skyline::TestSection.new(:body_a => s1.body_a(true), :id => '')
        s2.fail_validation = false
        
        assert s2.save
        refs = Skyline::InlineRef.all(:conditions => {:refering_id => s2.id, :refering_type => s2.class.name, :refering_column_name => "body_a"})        
        assert_equal 2,refs.size
        
        referable_uris = refs.map(&:referable)
        uris = referable_uris.map(&:uri)
        
        assert_equal 2,referable_uris.select{|r| r.kind_of?(Skyline::ReferableUri) }.size
        assert_equal ["http://www.google.com", "http://www.digitpaint.nl"], uris
        
      end
      
    end
    
    
    context "on an object with callbacks" do
      
      should "not fail when after_create does another save" do
        class TS1 < Skyline::TestSection
          attr_accessor :skip_extra_save
          after_create :after_creating
          def after_creating
            return if self.skip_extra_save
            self.skip_extra_save = true            
            self.save
          end          
        end
        s1 = TS1.new(:body_a => "<a href=\"http://www.google.com\" skyline-referable-type=\"Skyline::ReferableUri\">Link1</a>link1</a>")
        
        assert s1.save
        assert_equal 1,Skyline::InlineRef.count(:conditions => {:refering_id => s1.id, :refering_type => s1.class.name, :refering_column_name => "body_a"})
        assert_nothing_raised{ s1.body_a(true) }
        
        s1.reload
        assert s1.save
        assert_equal 1,Skyline::InlineRef.count(:conditions => {:refering_id => s1.id, :refering_type => s1.class.name, :refering_column_name => "body_a"})
        assert_nothing_raised{ s1.body_a(true) }                
      end

      should "not fail when after_save does another save" do
        class TS2 < Skyline::TestSection
          attr_accessor :skip_extra_save
          after_save :after_saving
          def after_saving
            return if self.skip_extra_save
            self.skip_extra_save = true            
            self.save
          end          
        end
        s1 = TS2.new(:body_a => "<a href=\"http://www.google.com\" skyline-referable-type=\"Skyline::ReferableUri\">Link1</a>link1</a>")
        
        assert s1.save
        
        s1.reload
        assert s1.save
        assert_equal 1,Skyline::InlineRef.count(:conditions => {:refering_id => s1.id, :refering_type => s1.class.name, :refering_column_name => "body_a"})
        assert_nothing_raised{ s1.body_a(true) }                      
      end

      
    end
    
  end
  
end