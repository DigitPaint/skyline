Setting up Bundler for a Rails 2.3 application
==============================================

Requirements
------------

* Ruby >= 1.8.6
* Rubygems >= 1.3.5
* Rails >= 2.3.4
* Bundler 0.7.0

Setup bundler to provide all necessary gems
-------------------------------------------

Create the file `Gemfile` in your RAILS\_ROOT and add the following lines:

    bundle_path "vendor/bundler_gems"
    gem "rails"
    disable_system_gems
    
### Including extra Gemfiles?

To make sure bundler handles all the required gems including the ones from plugins use
the following code:

    my_gemfile = File.join(File.dirname(__FILE__), 'vendor', 'plugins', 'my_plugin', 'Gemfile')
    instance_eval(File.read(my_gemfile), my_gemfile)

Create initializer for Bundler
------------------------------

Create file called `config/preinitializer.rb` and add the follwoing line:

    require "#{File.dirname(__FILE__)}/../vendor/bundler_gems/environment"

Initialize Bundler before Rails boots
-------------------------------------

Add the following to `config/boot.rb`, just before the `Rails.boot!` statement.

    # for bundler
    class Rails::Boot
      def run
        load_initializer
        extend_environment
        Rails::Initializer.run(:set_load_path)
      end
      def extend_environment
        Rails::Initializer.class_eval do
          old_load = instance_method(:load_environment)
          define_method(:load_environment) do
            Bundler.require_env RAILS_ENV
            old_load.bind(self).call
          end
        end
      end
    end

Bundle your gems
----------------

    gem bundle

Using git?
----------
If you're using git we advise you to put the following lines in your .gitignore

    vendor/bundler_gems/doc
    vendor/bundler_gems/environment.rb
    vendor/bundler_gems/gems
    vendor/bundler_gems/specifications
