# To include these dependencies in your applition, place this in the /Gemfile:
#
# skyline_gemfile = File.join(File.dirname(__FILE__), 'vendor', 'plugins', 'skyline', 'Gemfile')
# instance_eval(File.read(skyline_gemfile), skyline_gemfile)
# 

source :rubygems

gem "rails", "3.0.9"
# gem "rack", "1.1.0"

# When changing these, make sure you also change:
#
#   * config/initializers/dependencies.rb !!
#   * Rakefile
#
# Otherwise the gem will not work!

gem "polyglot"
gem "sprockets", "1.0.2"
gem "mime-types", "1.16",                   :require => "mime/types"
gem "rmagick", "2.9.1",                     :require => "RMagick"
gem "hpricot", "0.8.2",                     :require => "hpricot"
gem "guid", "0.1.1"
gem "will_paginate", "~> 3.0.pre4"
gem "seed-fu", "~> 1.2.0"
gem "mail", "~>2.2.0" 
gem "personify", "~> 1.1.0"

group :test do
  gem "factory_girl_rails", "1.1.0"
  gem "shoulda", "2.9.1",        :require => "shoulda"
end
