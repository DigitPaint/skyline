require 'rubygems'
require 'shoulda'
require File.dirname(__FILE__) + "/../personify"

require 'test/unit'

module ParserTestHelper
  def parse(input)
    result = @parser.parse(input)
    unless result
      puts @parser.terminal_failures.join("\n")
    end
    assert !result.nil?
    result
  end
end