Factory.define :media_dir, :class => Skyline::MediaDir do |d|  
  d.name "test_dir"
end

Factory.define :media_file, :class => Skyline::MediaNode do |f|
  f.name 'test_file.jpg'
  f.content_type "image/jpeg"
  f.size "28521"
  f.path "test_dir"
  f.description "A test file"
end

Factory.define :user, :class => Skyline::User do |u|
  u.name "Test User"
  u.email "test@test.com"
end

Factory.define :page, :class => Skyline::Page do |u|
end

Factory.define :wysiwyg_section, :class => Skyline::Sections::WysiwygSection do |u|
end

Factory.define :rss_section, :class => Skyline::Sections::RssSection do |u|
end
