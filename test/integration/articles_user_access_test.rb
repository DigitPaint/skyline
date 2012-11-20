require 'test_helper'
require File.dirname(__FILE__) + '/../../db/fixtures/roles_and_rights.rb' 
require 'user_access_helper'
require 'mocks/custom_article'
require 'mocks/test_article'

class ArticlesUserAccessTest < ActionController::IntegrationTest
  include UserAccessHelper
  
  context "a CustomArticle (with right_prefix)" do
    setup do
      load File.dirname(__FILE__) + '/../../db/fixtures/roles_and_rights.rb' 
      
      @user = FactoryGirl.create(:user, :name => "Test User", :email => "test@test.com")
      assert !@user.new_record?
      
      @article = Skyline::CustomArticle.new
      assert_equal @article.right_prefix, 'custom_article'
    end
    
    should "not be editable by a default user" do
      assert !@article.editable_by?(@user)
    end
    
    should "be editable by a user with generic article_* rights" do
      role = FactoryGirl.create(:role, :name => 'article_editor')
      
      role.rights << Skyline::Right.find_by_name('article_update')
      role.rights << Skyline::Right.find_by_name('article_lock')
      @user.grants.create(:role_id => role.id)
      
      assert @article.editable_by?(@user)
    end
    
    context "with matching rights defined" do
      setup do
        @custom_article_role = FactoryGirl.create(:role, :name => 'custom_article_editor')
        
        @custom_article_role.rights << Skyline::Right.find_or_create_by_name('custom_article_update')
        @custom_article_role.rights << Skyline::Right.find_or_create_by_name('custom_article_lock')
        assert @custom_article_role.save
      end
      
      should "not be editable by a default user" do
        assert !@article.editable_by?(@user)
      end
      
      should "not be editable by a user with generic article_* rights" do
        role = FactoryGirl.create(:role, :name => 'article_editor')
        
        role.rights << Skyline::Right.find_by_name('article_update')
        role.rights << Skyline::Right.find_by_name('article_lock')
        @user.grants.create(:role_id => role.id)
        
        assert !@article.editable_by?(@user)
      end
      
      should "be editable by a user with matching rights" do
        @user.grants.create(:role_id => @custom_article_role.id)
        
        assert @article.editable_by?(@user)
      end
    end
  end
  
  context "a TestArticle (without right_prefix)" do
    setup do
      load File.dirname(__FILE__) + '/../../db/fixtures/roles_and_rights.rb' 
      
      @user = FactoryGirl.create(:user, :name => "Test User", :email => "test@test.com")
      assert !@user.new_record?
      
      @article = Skyline::TestArticle.new
      assert_equal @article.right_prefix, 'article', 'Subclasses should inherit right_prefix from Skyline::Article'
    end
    
    should "not be editable by a default user" do
      assert !@article.editable_by?(@user)
    end
    
    should "be editable by a user with generic article_* rights" do
      role = FactoryGirl.create(:role, :name => 'article_editor')
      
      role.rights << Skyline::Right.find_by_name('article_update')
      role.rights << Skyline::Right.find_by_name('article_lock')
      @user.grants.create(:role_id => role.id)
      
      assert @article.editable_by?(@user)
    end
    
    context "with matching rights defined" do
      setup do
        @test_article_role = FactoryGirl.create(:role, :name => 'test_article_editor')
        
        @test_article_role.rights << Skyline::Right.find_or_create_by_name('test_article_update')
        @test_article_role.rights << Skyline::Right.find_or_create_by_name('test_article_lock')
        assert @test_article_role.save
      end
      
      should "not be editable by a default user" do
        assert !@article.editable_by?(@user)
      end
      
      should "be editable by a user with generic article_* rights" do
        role = FactoryGirl.create(:role, :name => 'article_editor')
        
        role.rights << Skyline::Right.find_by_name('article_update')
        role.rights << Skyline::Right.find_by_name('article_lock')
        @user.grants.create(:role_id => role.id)
        
        assert @article.editable_by?(@user)
      end
      
      should "not be editable by a user with only matching rights" do
        @user.grants.create(:role_id => @test_article_role.id)
        
        assert !@user.allow?(:article_update), "User shouldn't have article_update role"
        
        assert !@article.editable_by?(@user), "User shouldn't be able to edit as right_prefix isn't set"
      end
    end
  end
  
end