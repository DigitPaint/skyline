require File.dirname(__FILE__) + '/mootools_on_rails/mootools_helper'

ActionView::Helpers::PrototypeHelper.instance_methods.each do |method|
  ActionView::Helpers::PrototypeHelper.send :remove_method, method
end

ActionView::Base.class_eval do
  include ActionView::Helpers::MootoolsHelper
end

# hack to render rjs code within controller thru the following syntax "render :update do |page| ...."
# definitively not the best way to handle this but since Rails is deeply tied to Prototype + Scriptaculous,
# we can not do much more than that.

module Mootools
  module JavascriptGeneratorShunt
    def include_helpers_from_context        
      extend @context.helpers if @context.respond_to?(:helpers)
      extend ActionView::Helpers::MootoolsHelper::JavaScriptGenerator::GeneratorMethods
    end
  end
end

# remove the original method...
ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.send(:remove_method, :include_helpers_from_context)

# ...and replace it by the mootools one :-)
ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.class_eval do
  include Mootools::JavascriptGeneratorShunt
end
