require 'pathname'
require 'fileutils'

module Skyline
  module Cli
    # @private
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
            
          raise Thor::Error, "This does not seem like a valid Rails app (need lib, public and config/environment.rb)"
        end
      end
      
      def add_config_gem
        environment_rb = (self.target_dir + "config/environment.rb")
        if File.read(environment_rb) =~ /^\s*config.gem\s+[\":']skylinecms[\"']?(.+[\":']version[\"']?\s*=>\s*[\"'](.+)[\"'])?/i
          say_status "exist", "Already found gem version #{$2}, not doing anything, check gem dependency manually", :blue
        else
          say "=> Adding config.gem line to environment.rb"
          inject_into_file environment_rb, :after => "Rails::Initializer.run do |config|\n" do
            "  config.gem \"skylinecms\", :version => \"#{Skyline::VERSION::STRING}\"\n"
          end
        end
      end
      
      def create_stub_tasks_file
        tasks_dir = (self.target_dir + "lib/tasks")
        
        say "=> Creating lib/tasks directory"
        empty_directory tasks_dir
        
        say "=> Creating lib/tasks/skyline.rake"
        copy_file self.template_dir + "tasks/skyline.rake", tasks_dir + "skyline.rake"
      end
      
      def copy_assets
        say "=> Copying assets"
        
        public_dir = (self.target_dir + "public/skyline")
        if public_dir.exist? || File.symlink?(public_dir)
          if shell.file_collision("public/skyline")
            FileUtils.rm_rf(public_dir)
          else
            return
          end
        end
        
        directory "public/skyline/images", public_dir + "images", :recursive => true
        directory "public/skyline/stylesheets", public_dir + "stylesheets", :recursive => true        
        directory "public/skyline/javascripts", public_dir + "javascripts", :recursive => true                
      end
      
      def create_skyline_config
        say "=> Creating config/initializers/skyline_configuration.rb"
        copy_file self.template_dir + "config/initializers/skyline_configuration.rb", self.target_dir + "config/initializers/skyline_configuration.rb"
      end
      
      def create_development_upload_paths
        say "=> Creating development upload paths"
        empty_directory self.target_dir + "tmp"
        empty_directory self.target_dir + "tmp/upload"        
        empty_directory self.target_dir + "tmp/cache/media_files/cache"
        empty_directory self.target_dir + "tmp/cache/rss_sections/cache"        
      end
      
      def create_template_path
        say "=> Creating skyline template path"
        empty_directory self.target_dir + "app/templates"
      end
      
      def add_default_pages_route
        routes_rb = self.target_dir + "config/routes.rb"
        route_string = "map.connect '*url', :controller => \"skyline/site/pages\", :action => \"show\""
        
        say "=> Add default pages route"
        if File.read(routes_rb) =~ /#{Regexp.escape(route_string)}$/
          say_status "exist", "default pages route", :blue
        else
          inject_into_file routes_rb, :after => "map.connect ':controller/:action/:id.:format'\n" do
            "\n" +
            "  # The default Skyline pages route\n" +
            "  #{route_string}\n"
          end
        end
      end
      
      def remove_default_rails_assets
        say "=> Removing default rails assets"
        %w{public/index.html public/images/rails.png}.each do |f|
          if (self.target_dir + f).exist?
            say_status "removing", f
            FileUtils.rm(self.target_dir + f)
          end
        end
      end
      
      protected
      
      def target_dir
        @_target_dir ||= Pathname.new(Dir.pwd)
      end
      
      def template_dir
        @_template_dir ||= self.class.source_root + "lib/skyline/cli/init/templates/"
      end
      
    end
  end
end