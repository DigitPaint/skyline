# To include these dependencies in your applition, place this in the /Gemfile:
#
# #  To setup run:  gem bundle --build-options build_options.yml
# 
# skyline_gemfile = File.join(File.dirname(__FILE__), 'vendor', 'plugins', 'skyline', 'Gemfile')
# instance_eval(File.read(skyline_gemfile), skyline_gemfile)
# 
# bundle_path "vendor/bundler_gems"
# 
# disable_system_gems


source "http://gems.github.com"
source "http://rubygems.org"

gem "rails", "2.3.10"
gem "rack", "1.1.0"

# When changing these, make sure you also change:
#
#   * config/initializers/dependencies.rb !!
#   * Rakefile
#
# Otherwise the gem will not work!

gem "polyglot", "0.2.6"
gem "sprockets", "1.0.2"
gem "mime-types", "1.16",                   :require => "mime/types"
gem "rmagick", "2.9.1",                     :require => "RMagick"
gem "hpricot", "0.8.2",                     :require => "hpricot"
gem "guid", "0.1.1"
gem "will_paginate", "~>2.3.15"
gem "seed-fu", "~>1.2.0"

# If you want to use the (outdated) rsolr interface, please 
# add the following two gems to your implementation Gemfile.
#
# gem "curb", "0.4.2.0"
# gem "mwmitchell-rsolr", "0.8.8",            :require => "rsolr"
# gem "mwmitchell-rsolr-ext", "0.7.35",       :require => "rsolr-ext"

group :test do
  gem "thoughtbot-factory_girl", "1.2.0",   :require => "factory_girl"
  gem "thoughtbot-shoulda", "2.9.1",        :require => "shoulda"
end
