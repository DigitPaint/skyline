require 'skyline/javascript_generator_methods'
ActionView::Helpers::MootoolsHelper::JavaScriptGenerator::GeneratorMethods.class_eval do
  include Skyline::JavascriptGeneratorMethods
end
