Setting up Bundler 1.x for a Rails 2.3 application
==============================================

Requirements
------------

* Ruby >= 1.8.7
* Rubygems >= 1.3.7
* Rails >= 2.3.10
* Bundler >= 1.0.0

Setup bundler to provide all necessary gems
-------------------------------------------

Create the file `Gemfile` in your RAILS\_ROOT and add the following lines:

  source :rubygems
  gem "rails"
    
### Including extra Gemfiles?

To make sure bundler handles all the required gems including the ones from plugins use
the following code:

    my_gemfile = File.join(File.dirname(__FILE__), 'vendor', 'plugins', 'my_plugin', 'Gemfile')
    instance_eval(File.read(my_gemfile), my_gemfile)

Create initializer for Bundler
------------------------------

Create file called `config/preinitializer.rb` and add the follwoing line:

    begin
      require "rubygems"
      require "bundler"
    rescue LoadError
      raise "Could not load the bundler gem. Install it with `gem install bundler`."
    end

    if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.24")
      raise RuntimeError, "Your bundler version is too old for Rails 2.3." +
       "Run `gem install bundler` to upgrade."
    end

    begin
      # Set up load paths for all bundled gems
      ENV["BUNDLE_GEMFILE"] = File.expand_path("../../Gemfile", __FILE__)
      Bundler.setup
    rescue Bundler::GemNotFound
      raise RuntimeError, "Bundler couldn't find some gems." +
        "Did you run `bundle install`?"
    end

Initialize Bundler before Rails boots
-------------------------------------

Add the following to `config/boot.rb`, just before the `Rails.boot!` statement.

    class Rails::Boot
      def run
        load_initializer

        Rails::Initializer.class_eval do
          def load_gems
            @bundler_loaded ||= Bundler.require :default, Rails.env
          end
        end

        Rails::Initializer.run(:set_load_path)
      end
    end

Bundle your gems
----------------

    gem bundle