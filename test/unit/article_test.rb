require 'test_helper'
require 'mocks/test_article'
require 'mocks/test_section'
require 'pp'

class Skyline::ArticleTest < ActiveSupport::TestCase
  
  def create_article
    a = Skyline::TestArticle.new
    variant = a.variants.first
    variant.data.intro = "This is my published body"
    variant.sections << Skyline::Section.new(:sectionable => Skyline::TestSection.new)
    
    assert a.save
    assert variant.publish
    
    variant.data.intro = "This is my unpublished body"
    assert variant.save
        
    a.reload
    
    assert_equal "This is my unpublished body", a.default_variant.data.intro
    
    assert_equal 1, a.variants.size
    assert a.published_publication
    assert_equal 1, a.publications.size
    a
  end

  def pretty(article)
    
    insp = lambda{|v|
      v.kind_of?(ActiveRecord::Base) ? "#{v.object_id}, #{v.id}" : v.inspect
    }
    
    puts "-"*20
    puts "#{article.class}  (#{article.object_id})"
    %w{id 
      published_publication_id 
      published_publication 
      published_publication_data_id 
      published_publication_data 
      default_variant_id 
      default_variant
      default_variant_data_id
      default_variant_data}.each do |f|
      puts "  #{f.ljust(30)} : #{insp.call(article.send(f))}"
    end
    
    p = lambda{|v|
      puts "    #{v.class} (#{v.object_id})"
      %w{
        id
        article_id
        article
        data_id
        data
      }.each do |f|
        puts "      #{f.ljust(30)} : #{insp.call(v.send(f))}"
      end
      
      puts "      -- DATA --"
      puts "        #{v.data.inspect}"        
    }
    puts "  - VARIANTS"
    article.variants.each(&p)
    puts "  - PUBLICATIONS"    
    article.publications.each(&p)    
        
    puts "-"*20    
  end
  
  context "A cloned Article" do
    setup do

      @article = create_article
      
      @orig = {}
      @orig[:variants] = @article.variants.to_a
      @orig[:default_variant] = @article.default_variant
      @orig[:default_variant_data] = @article.default_variant_data
      
      @clone = @article.clone
    end
    
    should "be a new record" do
      assert @clone.new_record?
    end
    
    should "have cloned variants" do
      cv = @clone.variants.first
      
      assert_not_equal @orig[:variants].first, cv
      
      @clone.variants.each{|cv| assert cv.new_record? }
    end
    
    should "have a cloned default_variant_data" do
      assert_not_equal @clone.default_variant_data, @orig[:default_variant_data]
    end
    
    should "have a cloned default_variant" do
      assert_not_equal @clone.default_variant, @orig[:default_variant]      
    end
    
    context "that has been saved" do
      setup do
        assert @clone.save
        @article.reload
      end
      
      should "have cloned variants" do
        assert_not_equal @orig[:variants].first.id, @clone.variants.first.id
      end
      
      should "have a cloned default_variant" do
        assert @clone.default_variant
        assert_not_equal @orig[:default_variant].id, @clone.default_variant_id
      end
      
      should "have a cloned default_variant_data" do
        assert @clone.default_variant_data_id        
        assert_not_equal @orig[:default_variant_data].id, @clone.default_variant_data_id
      end
      
      should "not have modified the original variants" do
        assert_equal @orig[:variants].first.id, @article.variants.first.id        
      end
      
      should "not have modified the original default_variant" do
        assert_equal @orig[:default_variant].id, @article.default_variant_id
      end
      
      should "not have modified the original default_variant_data" do
        assert_equal @orig[:default_variant_data].id, @article.default_variant_data_id
      end
      
    end
        
  end
end

