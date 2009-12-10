require 'thor'

require File.dirname(__FILE__) + '/init'
require File.dirname(__FILE__) + '/../../skyline'
require File.dirname(__FILE__) + '/../version'

module Skyline
  module Cli
    class Base < Thor
      include Thor::Actions
      
      add_runtime_options!      
      
      desc "init", "Setup Skyline in the current directory, this must be a valid Rails 2.3 application."
      def init
        invoke Skyline::Cli::Init
      end
      
    end
  end
end