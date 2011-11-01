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

Create an empty rails app. 

    rails new my_app
    cd my_app

Installation as a packaged gem
---------------------

Edit the Gemfile and add

    gem "skylinecms"
    
Continue with "Run bundler".

Installation as a local gem
-----------------------

Download the Skyline source from [http://github.com/DigitPaint/skyline](http://github.com/DigitPaint/skyline).
You can use it as a Git submodule or yust download the zip version and unpack it to
`vendor/skylinecms`

If you're using bundler, add the following to your `Gemfile`

  gem "skylinecms", :path => "vendor/skylinecms"

Run bundler
-----------

Just run bundle install to fetch and install all dependencies:

    bundle install

Bootstrap skyline
-----------------

Run the skyline init script to initialize all required configurations. You might want to skip this step
if you want to update Skyline frequently (you can do most of these steps by hand: see below)

    bundle exec skylinecms init

Setup your database
-------------------

Modify `config/database.yml` to match your database configuration if needed. Run:

    rake db:create
    rake skyline:db:migrate
    rake skyline:db:seed
    
Create your first user and grant him/her access
-----------------------------------------------

Open a Rails console by running `rails console`

    user = Skyline::User.new(:email => 'admin@admin.com', :password => 'secret')
    user.grants.build(:role => Skyline::Role.find_by_name("super"))
    user.save

Make sure the user exists in the database.

Boot your server!
-----------------

You should be good to go. Start your server:

    rails server
    
and browse to *http://localhost:9000/skyline* to reach Skyline. 

Where to go from here?
----------------------

* Check the documentation
* Look at our [sample implementation on github](http://github.com/DigitPaint/skyline_demo_site)
* Roam around our Google Group ([http://groups.google.com/group/skylinecms](http://groups.google.com/group/skylinecms))
* Follow us on twitter [@skylinecms](http://twitter.com/skylinecms)


Configurating Skyline manually
------------------------------

### Create configuration file

Create a Rails initializer in `config/initializers` (we call it `skyline_configuration.rb`) and
add the following:

    Skyline::Configuration.configure do |config|  
      config.assets_path = File.join(Rails.root,"tmp/upload")
      config.media_file_cache_path = File.join(Rails.root,"tmp/cache/media_files/cache")
    end

### Create template folder

Create the template folder in your `app` directory.

    mkdir app/templates

### Add default route for pages

Open `config/routes.rb` and add the default Skyline route below all other routes:

    match '(*url)', :to => "skyline/site/pages#show", :constraints => Skyline::RouteConstraint