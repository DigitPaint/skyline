require 'digest/sha1'
require 'ipaddr'
require 'rss/2.0'
require 'open-uri'

require 'andand/andand'
require 'weppos/url_validation'
require 'digitpaint/unique_identifiers'
require 'digitpaint/configure'
require 'digitpaint/nested_attributes_positioning'
require 'mootools-on-rails/lib/mootools_on_rails'

require 'personify'
require "polyglot"
require "sprockets"
require "mime/types"
require "RMagick"
require "hpricot"
require "guid"
require "will_paginate"
require "seed-fu"

# If you are upgrading skyline from pre 3.0.8, it's easier to enable the
# deprecation layer.
# require 'skyline/deprecated/version3_0_8'