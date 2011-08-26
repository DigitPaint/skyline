Skyline installation instructions
=================================

Choose your flavour
-------------------

**Install as a packaged gem** The skylinecms gem is perfect if you want to have stable environment
and don't care too much about cutting-edge new features. We release new versions fairly
often.

**Install as a local gem** Use the "local" gem if you want to be on the latest development version
with all the 'cool' new features. Especially if you use git, because we're hosting the
source on github. 

Create your rails app
---------------------

Create an empty rails app. Make sure you're usin MySQL for now,
we didn't test with other databases yet.

    rails new my_app --database=mysql
    cd my_app

Installation as a packaged gem
---------------------

Install the gems, and initialize Skyline. 

    gem install skylinecms
    skylincms init
    
Continue below.

Installation as a local gem
-----------------------

Download the Skyline source from [http://github.com/DigitPaint/skyline](http://github.com/DigitPaint/skyline).
You can use it as a Git submodule or yust download the zip version and unpack it to
`vendor/skyline`

If you're using bundler, add the following to your `Gemfile`

  gem "skylinecms", :path => "vendor/skyline"
  
Run `bundle` and you're done!


Setup your database
-------------------

Modify `config/database.yml` to match your database configuration and then run:

    rake db:create
    rake skyline:db:migrate
    rake skyline:db:seed
    
Create your first user and grant him/her access
-----------------------------------------------

Open a Rails console by running `./script/console`

    u = Skyline::User.new(:email => 'admin@admin.com', :password => 'secret')
    u.roles << Skyline::Role.first
    u.save!

Make sure the user exists in the database.

If you went the "gem route" you're done now just start the server with `./script/server`
and browse to `http://localhost:3000/skyline` and log in with the just created user.

Extra work when using the plugin
--------------------------------

### Create configuration file

Create a Rails initializer in `config/initializers` (we call it `skyline_configuration.rb`) and
add the following:

    Skyline::Configuration.configure do |config|  
      config.assets_path = File.join(Rails.root,"tmp/upload")
      config.media_file_cache_path = File.join(Rails.root,"tmp/cache/media_files/cache")
      config.rss_section_cache_path = File.join(Rails.root,"tmp/cache/rss_sections/cache")   
    end

### Create template folder

Create the template folder in your `app` directory.

    mkdir app/templates

### Add default route for pages

Open `config/routes.rb` and add the default Skyline route below all other routes:

    match '(*url)', :to => "pages#show", :constraints => Skyline::RouteConstraint