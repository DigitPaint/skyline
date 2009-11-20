require File.dirname(__FILE__) + "/../vendor/treetop/lib/treetop"

target_dir = File.dirname(__FILE__) + "/../lib/parser/"

compiler = Treetop::Compiler::GrammarCompiler.new
compiler.compile(File.join(target_dir,"personify.treetop"), File.join(target_dir,"personify.rb"))