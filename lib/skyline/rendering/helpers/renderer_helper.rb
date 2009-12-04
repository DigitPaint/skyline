# We have this in here so YARD recognizes the module nesting
module Skyline::Rendering
  module Helpers
    module RendererHelper
      def assign(key, value = nil)
        return @_template_assigns[key] if value.nil?
        @_template_assigns[key] = value
      end

      # Get's the current Renderer instance that is rendering the template we're in.
      # 
      # @return [Skyline::Renderer] The renderer
      def renderer
        @_renderer
      end

      # @see Skyline::Renderer#render
      def render_object(object, options = {})
        renderer.render(object, options)
      end

      # @see Skyline::Renderer#render_collection
      def render_collection(objects, options = {},&block)
        renderer.render_collection(objects, options, &block)
      end

      # @see Skyline::Renderer#peek
      def peek(n=1, &block)
        renderer.peek(n, &block)
      end

      # @see Skyline::Renderer#peek_until} 
      def peek_until(&block)
        renderer.peek_until(&block)
      end

      # @see Skyline::Renderer#render_until
      def render_until(&block)
        renderer.render_until(&block)
      end    

      # @see Skyline::Renderer#skip!
      def skip!(n=1)
        renderer.skip!(n)
      end

      # @see Skyline::Renderer#skip_until!
      def skip_until!(&block)
        renderer.skip_until!(&block)
      end

      # @see ActionController::Request#session  
      def session
        @_controller.session
      end

      # @see ActionController::Request#params 
      def params
        @_controller.params
      end

      # @see ActionController::Cookies#cookies
      def cookies
        @_controller.cookies
      end

      # The request that's currently being processed
      #
      # @return ActiveRecord::Request  
      def request
        @_controller.request
      end

      def flash
        @_controller.send(:flash)
      end

      # The site that's currently in scope for this template
      #
      # @return Skyline::Site
      def site
        @_site
      end

      # @see ActionView::Helpers::UrlHelper#url_for
      def url_for(options = {})
        options ||= {}
        url = case options
        when String
          super
        when Hash
          options = { :only_path => options[:host].nil? }.update(options.symbolize_keys)
          escape  = options.key?(:escape) ? options.delete(:escape) : true
          @_controller.send(:url_for, options)
        when :back
          escape = false
          @_controller.request.env["HTTP_REFERER"] || 'javascript:history.back()'
        else
          super
        end

        escape ? escape_once(url) : url
      end

      # @see ActionController::RequestForgeryProtection#protect_against_forgery?
      def protect_against_forgery?
        @_controller.send(:protect_against_forgery?)
      end

      # @see ActionController::RequestForgeryProtection#request_forgery_protection_token
      def request_forgery_protection_token
        @_controller.request_forgery_protection_token
      end

      # @see ActionController::RequestForgeryProtection#form_authenticity_token
      def form_authenticity_token
        @_controller.send(:form_authenticity_token)
      end

      # Simple, quick 'n dirty solution so you can use 'acticle_version', 'news_item', .. in all 
      # your templates. So you don't have to use @.... or pass the local to all partials.
      # 
      # @private
      def method_missing(method, *params, &block)
        return @_local_object if @_local_object_name == method
        super
      end
    end
  end
end