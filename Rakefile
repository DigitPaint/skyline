require File.dirname(__FILE__) + "/lib/skyline"
require File.dirname(__FILE__) + "/lib/skyline/version"

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

namespace :doc do
  desc "Generate the Skyline CMS documentation (uses Yard)"
  YARD::Rake::YardocTask.new(:generate) do |t|
    t.options = ["-o#{OPTIONS["doc"]["output_path"]}", "--title=\"Skyline #{Skyline.version} API documentation\""]
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