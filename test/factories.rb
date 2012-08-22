require 'factory_girl'

FactoryGirl.define do
  factory :media_dir, :class => Skyline::MediaDir do |d|  
    d.name "test_dir"
  end

  factory :media_file, :class => Skyline::MediaNode do |f|
    f.name 'test_file.jpg'
    f.content_type "image/jpeg"
    f.size "28521"
    f.path "test_dir"
    f.description "A test file"
  end
  
  factory :role, :class => Skyline::Role do
    name "testrole"
  end
  
  factory :grant, :class => Skyline::Grant do |g|
    g.association(:role)
  end

  factory :user, :class => Skyline::User do |u|
    u.name "Test User"
    u.email "test@test.com"
    u.skip_current_user_validation true
    u.after_build do |user|
      user.grants << FactoryGirl.build(:grant)
    end
  end

  factory :page, :class => Skyline::Page
  factory :wysiwyg_section, :class => Skyline::Sections::WysiwygSection
  factory :rss_section, :class => Skyline::Sections::RssSection
  factory :user_preference, :class => Skyline::UserPreference
end
