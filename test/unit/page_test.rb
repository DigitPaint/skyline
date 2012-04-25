require 'test_helper'

class Skyline::PageTest < ActiveSupport::TestCase
  context "A new page" do
    setup do
      @page = FactoryGirl.create(:page)
      assert !@page.new_record?      
    end

    should "have one variant" do
      assert_equal 1, @page.variants.size
    end            
  end
      
  context "A page" do
    setup do
      @page = FactoryGirl.create(:page)
      assert !@page.new_record?      
      
      @variant = @page.variants.first
      @section_a = @variant.sections.create
      @section_b = @variant.sections.create
      @section_c = @variant.sections.create
      
      @section_a.sectionable = FactoryGirl.create(:wysiwyg_section, :body => "Hallo, dit is de body")
      @section_b.sectionable = FactoryGirl.create(:wysiwyg_section, :body => "Tweede sectie!")
      @section_c.sectionable = FactoryGirl.create(:rss_section, :url => "http://www.google.nl/x.rss", :show_count => 1)
      
      @section_a.save
      @section_b.save
      @section_c.save
      
      @variant.reload
    end

    should "have 3 sections when 3 sections are created" do
      assert_equal 3, @page.variants.first.sections.size
    end
    
    should "not be publishable when its not saved" do 
      @variant.data.url_part = "test"
      assert_raise(StandardError) {@variant.publish}
    end
    
    should "be publishable" do
      @variant.data.url_part = "test"
      @variant.save
      assert published_publication = @variant.publish
      
      assert_not_equal published_publication, @variant
      
      # published publication should have its own sections
      assert_equal [], published_publication.sections.collect{|s| s.id} & @variant.sections.collect{|s| s.id}   
      
      # published publication should have its own sectionables
      assert_equal [], published_publication.sections.collect{|s| s.sectionable.id} & @variant.sections.collect{|s| s.sectionable.id} 
    end
    
    should "should reference the published publication via .published_publication" do
      @variant.data.url_part = "test"
      @variant.save
      publised_publication = @variant.publish
      
      assert_equal publised_publication, @variant.page.published_publication
      assert_equal publised_publication.variant, @variant
    end
    
    should "should always keep the variant of a published publication" do
      @variant.data.url_part = "test"
      @variant.save
      publised_publication = @variant.publish
      
      assert_raise(StandardError) {@variant.destroy}
    end
    
    should "be destroyed when the last variant is destroyed" do
      assert !@variant.page.frozen?
      @variant.destroy
      assert @variant.page.frozen?
    end
    
    should "have the published variant know its the published variant" do
      @variant.data.url_part = "test"
      @variant.save      
      @variant.publish
      assert @variant.published_variant?
    end
    
    should "have the published variant know whether is has been modified" do
      @variant.attributes = {:data_attributes => {:class => @variant.article.data_class.name, :url_part => "test"}}
      @variant.save      
      @variant.reload
       
      @variant.publish
      assert_equal true, @variant.identical_published_variant?
      @variant.data.custom_title_tag = "testing 123"
      @variant.save
      assert_equal false, @variant.identical_published_variant?
    end

    should "have the published variant know it has been modified when a section is modified via accepts_nested_attributes_for" do
      @variant.attributes = {:data_attributes => {:class => @variant.article.data_class.name, :url_part => "test"}}
      @variant.save      
      @variant.reload
      
      @variant.publish

      assert_equal true, @variant.identical_published_variant?
      @variant.attributes = {"sections_attributes" => {1 => {'id' => @section_a.id, 'sectionable_attributes' => {'id' => @section_a.sectionable_id, 'body' => 'pino'}}}}
      @variant.save
      assert_equal false, @variant.identical_published_variant?
    end
    
    should "be able to rollback a publication" do
      assert_equal [@variant], @variant.page.variants(true)
      
      @variant.data.url_part = "test"
      @variant.save      
      @variant.publish

      assert_equal [@variant], @variant.page.variants(true)

      publication = @variant.page.publications(true).first
      variant = publication.rollback({'name' => "nieuwe variant"})
      assert_not_equal publication, variant
      assert_equal "nieuwe variant", variant.name
      assert_equal publication.data.title, variant.data.title
      assert_equal publication.version, variant.version

      # @variant.page.variants contains exactly @variant and variant (no matter which order)
      assert_equal 2, ([@variant, variant] & @variant.page.variants(true)).size
    end
    
    should "let a variant to be saved when a version attribute is set and it matches the current version" do
      @variant.data.url_part = "test"
      @variant.version = @variant.version
      assert @variant.save
    end

    should "not let a variant to be saved when the actual version is higher than the version of the variant when it was retrieved" do
      variant_id = @variant.id
      current_version = @variant.version
      
      # bob sends a POST request to save the Variant
      bobs_variant = Skyline::Variant.find_by_id(variant_id)
      bobs_variant.attributes = {:version => current_version, :data_attributes => {:class => bobs_variant.article.data_class.name, :url_part => "bob's url_part"}}
      assert bobs_variant.save
      
      # alice's save will fail
      alices_variant = Skyline::Variant.find_by_id(variant_id)
      bobs_variant_version = alices_variant.version
      alices_variant.attributes = {:version => current_version, :data_attributes => {:class => alices_variant.article.data_class.name, :url_part => "alice's url_part"}}
      assert !alices_variant.save      
      
      # after confirming she really wants to overwrite Bob's changes she can save the Variant by specifying Bob's version number
      # if someone again edits the Variant between the save and confirmation the same problem and question arrises
      alices_variant = Skyline::Variant.find(variant_id)
      alices_variant.attributes = {:version => bobs_variant_version, :data_attributes => {:class => alices_variant.article.data_class.name, :url_part => "alice's url_part"}}
      assert alices_variant.save
    end
    
    should "return the published variant as default_variant if the page is published" do
      @variant.data.url_part = "test"
      @variant.save
      @variant.publish
      assert_equal @variant, @variant.page.default_variant
    end

    should "return the last published variant as default_variant if the page is not published *anymore*" do
      @variant.attributes = {:data_attributes => {:class => @variant.article.data_class.name, :url_part => "test"}}
      @variant.save      
      @variant.reload
        
      @variant.publish
      @variant.page.depublish
      assert_equal @variant, @variant.page.default_variant(true)
      
      new_variant = @variant.clone
      new_variant.save
      new_variant.publish
      
      new_variant.page.depublish

      @variant.reload
      assert_equal new_variant, @variant.page.default_variant(true)
    end

    should "return the last edited variant as default_variant if the page is *never* published" do
      @variant.attributes = {:data_attributes => {:class => @variant.article.data_class.name, :url_part => "test"}}
      @variant.save      
      @variant.reload
      
      Skyline::Page.connection.execute("UPDATE skyline_article_versions SET updated_at='2009-01-01' WHERE id=#{@variant.id}")
      assert_equal @variant, @variant.page.default_variant(true)

      new_variant = @variant.clone
      new_variant.save
      
      @variant.article.set_default_variant!(new_variant)
      
      assert_equal new_variant, @variant.page.default_variant(true)
    end
  end  
end
