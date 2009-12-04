Skyline installation instructions
=================================

Create the file 'Gemfile' in the root of your application
---------------------------------------------------------
Add the following contents:

    #  To bundle all gems run:  gem bundle --build-options build_options.yml
    skyline_gemfile = File.join(File.dirname(__FILE__), 'vendor', 'plugins', 'skyline', 'Gemfile')
    instance_eval(File.read(skyline_gemfile), skyline_gemfile)
    bundle_path "vendor/bundler_gems"
    disable_system_gems


Create the file 'build_options.yml' in the root of your application
-------------------------------------------------------------------
You only need this if your system needs specific build options

    mysql:
      mysql-config: /usr/bin/mysql_config


Create the file config/preinitializer.rb
----------------------------------------

    require "#{File.dirname(__FILE__)}/../vendor/bundler_gems/environment"
 

Add to config/environment.rb (just below the require boot line)
--------------------------------------------------------------------

    # Hijack rails initializer to load the bundler gem environment before loading the rails environment.
    Rails::Initializer.module_eval do
      alias load_environment_without_bundler load_environment

      def load_environment
        Bundler.require_env configuration.environment
        load_environment_without_bundler
      end
    end


Add to .gitignore:
------------------
If you're using git.

    bin
    vendor/bundler_gems/doc
    vendor/bundler_gems/environment.rb
    vendor/bundler_gems/gems
    vendor/bundler_gems/specifications


Add to config/deploy.rb:
------------------------

    task :bundle, :roles => [:app] do
      run "mkdir -p #{deploy_to}/shared/bundler_gems/gems #{deploy_to}/shared/bundler_gems/specifications"
      run "cd #{current_path}/vendor/bundler_gems; ln -fs #{deploy_to}/shared/bundler_gems/gems"
      run "cd #{current_path}/vendor/bundler_gems; ln -fs #{deploy_to}/shared/bundler_gems/specifications"
      run "cd #{current_path}; gem bundle --build-options build_options.yml"
    end
  
    after "deploy", ....., "deploy:bundle"
