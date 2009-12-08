require 'pathname'
require 'fileutils'

module Skyline
  module Cli
    class Init < Thor::Group
      include Thor::Actions
      
      def self.source_root
        Skyline.root
      end
      
      def verify_rails_dir
        say "=> Verifying if this is a Rails(like) app"
        unless (self.target_dir + "lib").exist? &&
            (self.target_dir + "public").exist? &&
            (self.target_dir + "config/environment.rb").exist?
            
          say "This does not seem like a valid Rails app (need lib, public and config/environment.rb)"
          exit
        end
      end
      
      def add_config_gem
        environment_rb = (self.target_dir + "config/environment.rb")
        if File.read(environment_rb) =~ /^\s*config.gem\s+[\":']skylinecms[\"']?(.+[\":']version[\"']?\s*=>\s*[\"'](.+)[\"'])?/i
          say "=> [WARN] Already found gem version #{$2}, not doing anything, check gem dependency manually"
        else
          say "=> Adding config.gem line to environment.rb"
          inject_into_file environment_rb, :after => "Rails::Initializer.run do |config|\n" do
            "  config.gem \"skylinecms\", :version => \"#{Skyline::VERSION::STRING}\"\n"
          end
        end
      end
      
      def create_stub_tasks_file
        tasks_dir = (self.target_dir + "lib/tasks")
        unless tasks_dir.exist?
          say "=> Creating lib/tasks directory"
          FileUtils.mdkir_p(tasks_dir)
        end
        say "=> Creating lib/tasks/skyline.rake"
        copy_file "lib/skyline/cli/init/templates/skyline.rake", tasks_dir + "skyline.rake"
      end
      
      def copy_assets
        say "=> Copying assets"
        
        public_dir = (self.target_dir + "public/skyline")
        if public_dir.exist? || File.symlink?(public_dir)
          if yes?("?> public/skyline already exists, overwrite? (yes,no)",:red)
            FileUtils.rm_rf(public_dir)
          else
            exit
          end
        end
        
        directory "public/skyline/images", public_dir + "images", :recursive => true
        directory "public/skyline/stylesheets", public_dir + "stylesheets", :recursive => true        
        directory "public/skyline/javascripts", public_dir + "javascripts", :recursive => true                
      end
      
      protected
      
      def target_dir
        @_target_id ||= Pathname.new(Dir.pwd)
      end
      
    end
  end
end