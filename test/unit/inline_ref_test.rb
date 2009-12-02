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
        html = "abcdefghi <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' /> <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' />"
        parsed_html, ids = Skyline::InlineRef.parse_html(html,@section,:body)
        assert_equal ids,Skyline::InlineRef.all(ids).map(&:id)
        assert_equal 2,Skyline::InlineRef.count(:conditions => {:refering_id => @section.id, :refering_type => @section.class.name})                

        new_html = "abcdefghi <img class='left' src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' /> <img src='' skyline-referable-id='1' skyline-referable-type='Skyline::Page' />"
        new_parsed_html, new_ids = Skyline::InlineRef.parse_html(html,@section,:body)        
        assert_equal new_ids,Skyline::InlineRef.all(new_ids).map(&:id)
        assert_equal 2,Skyline::InlineRef.count(:conditions => {:refering_id => @section.id, :refering_type => @section.class.name})        
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
    
    
  end
  
end