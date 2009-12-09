require File.dirname(__FILE__) + "/lib/skyline"
require File.dirname(__FILE__) + "/lib/skyline/version"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.version = Skyline.version
    gemspec.name = "skylinecms"
    gemspec.summary = "The new Ruby on Rails open source standard in content management"
    gemspec.description = "Skyline is an extremely flexible and expandable open source content management system. Its feature rich interface allows for fast and intuitive management of websites."
    gemspec.email = "info@digitpaint.nl"
    gemspec.homepage = "http://github.com/digitpaint/skyline"
    gemspec.authors = ["DigitPaint"]
    
    gemspec.files.exclude "tasks/testing.rake"
    gemspec.files.exclude "Gemfile"
    gemspec.files.exclude ".gitignore"
    gemspec.files.exclude "test"
    
    gemspec.test_files = []
    gemspec.has_rdoc = false
    
    gemspec.add_dependency "thor", "0.12.0"
    
    gemspec.add_dependency "rails", "2.3.5"
    gemspec.add_dependency "rack", "1.0.1"
    
    gemspec.add_dependency "polyglot", "0.2.6"
    gemspec.add_dependency "sprockets", "1.0.2"
    gemspec.add_dependency "mysql", "2.8.1"
    gemspec.add_dependency "mime-types", "1.16"
    gemspec.add_dependency "rmagick", "2.9.1"
    gemspec.add_dependency "hpricot", "0.6.164"
    gemspec.add_dependency "guid", "0.1.1"
    gemspec.add_dependency "mislav-will_paginate", "2.3.7"
    gemspec.add_dependency "curb", "0.4.2.0"
    gemspec.add_dependency "mwmitchell-rsolr", "0.8.8"
    gemspec.add_dependency "mwmitchell-rsolr-ext", "0.7.35"
    gemspec.add_dependency "mbleigh-seed-fu", "0.0.3"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end