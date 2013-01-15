# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "skyline"
require "skyline/version"

Gem::Specification.new do |s|
  s.name = "skylinecms"
  s.version = Skyline.version  
  s.authors = ["DigitPaint"]
  s.email = %q{info@digitpaint.nl}
  s.homepage = %q{http://www.skylinecms.nl}  
  s.description = %q{Skyline is an extremely flexible and expandable open source content management system. Its feature rich interface allows for fast and intuitive management of websites.}
  s.summary = %q{The new Ruby on Rails open source standard in content management}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.default_executable = "skylinecms"
  
  s.require_paths = ["lib"]  
  
  s.extra_rdoc_files = [
    "README.md",
    "doc/INSTALL.md",
    "doc/MIGRATION.md"
  ]
  
  s.files         = `git ls-files --exclude=.gitignore --exclude-standard`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  
  s.add_dependency "thor"
  s.add_dependency "rails", "~> 3.2.2"
  s.add_dependency "polyglot", "0.3.3"
  s.add_dependency "sprockets", "~> 2.2.1"
  s.add_dependency "mime-types", "1.19"
  s.add_dependency "rmagick", "2.13.1"
  s.add_dependency "hpricot", "0.8.6"
  s.add_dependency 'nokogiri'
  s.add_dependency "guid", "0.1.1"
  s.add_dependency "will_paginate", "~> 3.0.0"
  s.add_dependency "seed-fu", "2.2.0"
  s.add_dependency "mail", "~>2.4.1" 
  s.add_dependency "personify", "~> 1.1.0"
  s.add_dependency 'omniauth', "~> 1.1.0"
  s.add_dependency "bcrypt-ruby", "~> 3.0.1"
  s.add_dependency "sanitize", "~> 2.0.3"
  
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'shoulda'

end

