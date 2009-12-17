require File.dirname(__FILE__) + "/lib/skyline"
require File.dirname(__FILE__) + "/lib/skyline/version"

begin
  require 'jeweler'
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

begin
  require 'yard'
rescue LoadError
  puts "Yardoc not available. Install it with: sudo gem install yard"
end

require 'yaml'

DEFAULT_OPTIONS = {
  "doc" => {
    "output_path" => "ydoc",
    "deploy_to" => nil
  }
}

class Options < Hash
  def [](v)
    get_options!
    super(v)
  end
  
  
  
  def inspect
    get_options!
    super
  end
  
  private
  
  def get_options!
    return if @_loaded
    @_loaded = true
    
    self.update(DEFAULT_OPTIONS)
    
    f = File.expand_path("~/.skyline_options")    
    if File.exist?(f)
      opts = YAML.load(File.read(f))
      opts.each do |k,v|
        if self.has_key?(k)
          self[k].update(v)
        else
          self[k] = v
        end
      end
    end
    
  end
end
OPTIONS = Options.new

namespace :gem do
  Jeweler::Tasks.new do |gemspec|
    gemspec.version = Skyline.version
    gemspec.name = "skylinecms"
    gemspec.summary = "The new Ruby on Rails open source standard in content management"
    gemspec.description = "Skyline is an extremely flexible and expandable open source content management system. Its feature rich interface allows for fast and intuitive management of websites."
    gemspec.email = "info@digitpaint.nl"
    gemspec.homepage = "http://www.skylinecms.nl"
    gemspec.authors = ["DigitPaint"]
  
    gemspec.files.exclude "tasks/testing.rake"
    gemspec.files.exclude "Gemfile"
    gemspec.files.exclude ".gitignore"
    gemspec.files.exclude "test/"
  
    gemspec.test_files = []
  
    gemspec.has_rdoc = false
    gemspec.extra_rdoc_files = %w{README.md doc/MIGRATION.md}
  
    gemspec.add_dependency "thor", "0.12.0"
  
    gemspec.add_dependency "rails", "2.3.5"
    gemspec.add_dependency "rack", "1.0.1"
      
    gemspec.add_dependency "polyglot", "0.2.6"
    gemspec.add_dependency "sprockets", "1.0.2"
    gemspec.add_dependency "mime-types", "1.16"
    gemspec.add_dependency "rmagick", "2.9.1"
    gemspec.add_dependency "hpricot", "0.8.2"
    gemspec.add_dependency "guid", "0.1.1"
    gemspec.add_dependency "will_paginate", "~>2.3.11"
    gemspec.add_dependency "seed-fu", "~>1.2.0"
  
  end
end

namespace :doc do
  desc "Generate the Skyline CMS documentation (uses Yard)"
  YARD::Rake::YardocTask.new(:generate) do |t|
    t.options = ["-o#{OPTIONS["doc"]["output_path"]}"]
  end
  
  task :deploy do
    raise "No Options['doc']['deploy_to'] variable set, create a ~/.skyline_options YAML file and set it there" if OPTIONS["doc"]["deploy_to"].nil?
    
    puts "=> Generating YarDoc first."
    Rake::Task['doc:generate'].execute
    
    puts "=> Uploading documentation"
    Rake::Task['doc:upload'].execute
  end
  
  task :upload do
    system("rsync -az --delete #{OPTIONS["doc"]["output_path"]}/* #{OPTIONS["doc"]["deploy_to"]}")    
  end
end

task :options do
  puts OPTIONS.inspect
end