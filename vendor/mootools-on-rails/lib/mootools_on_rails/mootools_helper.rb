module ActionView
  module Helpers
    module MootoolsHelper
      CALLBACKS    = Set.new([:complete, :start, :cancel] +
                       (100..599).to_a)
                       
                       
     # Returns a link to a remote action defined by <tt>options[:url]</tt> 
     # (using the url_for format) that's called in the background using 
     # XMLHttpRequest. The result of that requestx can then be inserted into a
     # DOM object whose id can be specified with <tt>options[:update]</tt>. 
     # Usually, the result would be a partial prepared by the controller with
     # render :partial. 
     #
     # Examples:
     #   link_to_remote "Delete this post", :update => "posts", 
     #     :url => { :action => "destroy", :id => post.id }
     #   link_to_remote(image_tag("refresh"), :update => "emails", 
     #     :url => { :action => "list_emails" })
     # 
     # You can override the generated HTML options by specifying a hash in
     # <tt>options[:html]</tt>.
     #  
     #   link_to_remote "Delete this post", :update => "posts",
     #     :url  => post_url(@post), :method => :delete, 
     #     :html => { :class  => "destructive" } 
     #
     # You can also specify a hash for <tt>options[:update]</tt> to allow for
     # easy redirection of output to an other DOM element if a server-side 
     # error occurs:
     #
     # Example:
     #   link_to_remote "Delete this post",
     #     :url => { :action => "destroy", :id => post.id },
     #     :update => { :success => "posts", :failure => "error" }
     #
     # Optionally, you can use the <tt>options[:position]</tt> parameter to 
     # influence how the target DOM element is updated. It must be one of 
     # <tt>:before</tt>, <tt>:top</tt>, <tt>:bottom</tt>, or <tt>:after</tt>.
     #
     # The method used is by default POST. You can also specify GET or you
     # can simulate PUT or DELETE over POST. All specified with <tt>options[:method]</tt>
     #
     # Example:
     #   link_to_remote "Destroy", :url => person_url(:id => person), :method => :delete
     #
     # By default, these remote requests are processed asynchronous during 
     # which various JavaScript callbacks can be triggered (for progress 
     # indicators and the likes). All callbacks get access to the 
     # <tt>request</tt> object, which holds the underlying XMLHttpRequest. 
     #
     # To access the server response, use <tt>request.responseText</tt>, to
     # find out the HTTP status, use <tt>request.status</tt>.
     #
     # Example:
     #   link_to_remote word,
     #     :url => { :action => "undo", :n => word_counter },
     #     :complete => "undoRequestCompleted(request)"
     #
     # The callbacks that may be specified are (in order):
     #
     # <tt>:loading</tt>::       Called when the remote document is being 
     #                           loaded with data by the browser.
     # <tt>:loaded</tt>::        Called when the browser has finished loading
     #                           the remote document.
     # <tt>:interactive</tt>::   Called when the user can interact with the 
     #                           remote document, even though it has not 
     #                           finished loading.
     # <tt>:success</tt>::       Called when the XMLHttpRequest is completed,
     #                           and the HTTP status code is in the 2XX range.
     # <tt>:failure</tt>::       Called when the XMLHttpRequest is completed,
     #                           and the HTTP status code is not in the 2XX
     #                           range.
     # <tt>:complete</tt>::      Called when the XMLHttpRequest is complete 
     #                           (fires after success/failure if they are 
     #                           present).
     #                     
     # You can further refine <tt>:success</tt> and <tt>:failure</tt> by 
     # adding additional callbacks for specific status codes.
     #
     # Example:
     #   link_to_remote word,
     #     :url => { :action => "action" },
     #     404 => "alert('Not found...? Wrong URL...?')",
     #     :failure => "alert('HTTP Error ' + request.status + '!')"
     #
     # A status code callback overrides the success/failure handlers if 
     # present.
     #
     # If you for some reason or another need synchronous processing (that'll
     # block the browser while the request is happening), you can specify 
     # <tt>options[:type] = :synchronous</tt>.
     #
     # You can customize further browser side call logic by passing in
     # JavaScript code snippets via some optional parameters. In their order 
     # of use these are:
     #
     # <tt>:confirm</tt>::      Adds confirmation dialog.
     # <tt>:condition</tt>::    Perform remote request conditionally
     #                          by this expression. Use this to
     #                          describe browser-side conditions when
     #                          request should not be initiated.
     # <tt>:before</tt>::       Called before request is initiated.
     # <tt>:after</tt>::        Called immediately after request was
     #                          initiated and before <tt>:loading</tt>.
     # <tt>:submit</tt>::       Specifies the DOM element ID that's used
     #                          as the parent of the form elements. By 
     #                          default this is the current form, but
     #                          it could just as well be the ID of a
     #                          table row or any other DOM element.
     # <tt>:with</tt>::         A JavaScript expression specifying
     #                          the parameters for the XMLHttpRequest.
     #                          Any expressions should return a valid
     #                          URL query string.
     #
     #                          Example:
     #                          
     #                            :with => "'name=' + $('name').value"
     #
     # You can generate a link that uses AJAX in the general case, while 
     # degrading gracefully to plain link behavior in the absence of
     # JavaScript by setting <tt>html_options[:href]</tt> to an alternate URL.
     # Note the extra curly braces around the <tt>options</tt> hash separate
     # it as the second parameter from <tt>html_options</tt>, the third.
     #
     # Example:
     #   link_to_remote "Delete this post",
     #     { :update => "posts", :url => { :action => "destroy", :id => post.id } },
     #     :href => url_for(:action => "destroy", :id => post.id)
     def link_to_remote(name, options = {}, html_options = nil)  
       link_to_function(name, remote_function(options), html_options || options.delete(:html))
     end

     # Creates a form that will submit using XMLHttpRequest in the background 
     # instead of the regular reloading POST arrangement and a scope around a 
     # specific resource that is used as a base for questioning about
     # values for the fields.  
     #
     # === Resource 
     #
     # Example:
     #   <% remote_form_for(@post) do |f| %>
     #     ...
     #   <% end %>
     #
     # This will expand to be the same as:
     #
     #   <% remote_form_for :post, @post, :url => post_path(@post), :html => { :method => :put, :class => "edit_post", :id => "edit_post_45" } do |f| %>
     #     ...
     #   <% end %>
     #
     # === Nested Resource 
     #
     # Example:
     #   <% remote_form_for([@post, @comment]) do |f| %>
     #     ...
     #   <% end %>
     #
     # This will expand to be the same as:
     #
     #   <% remote_form_for :comment, @comment, :url => post_comment_path(@post, @comment), :html => { :method => :put, :class => "edit_comment", :id => "edit_comment_45" } do |f| %>
     #     ...
     #   <% end %>
     #
     # If you don't need to attach a form to a resource, then check out form_remote_tag.
     #
     # See FormHelper#form_for for additional semantics.
     def remote_form_for(record_or_name_or_array, *args, &proc)
       options = args.extract_options!

       case record_or_name_or_array
       when String, Symbol
         object_name = record_or_name_or_array
       when Array
         object = record_or_name_or_array.last
         object_name = ActionController::RecordIdentifier.singular_class_name(object)
         apply_form_for_options!(record_or_name_or_array, options)
         args.unshift object
       else
         object      = record_or_name_or_array
         object_name = ActionController::RecordIdentifier.singular_class_name(record_or_name_or_array)
         apply_form_for_options!(object, options)
         args.unshift object
       end

       concat(form_remote_tag(options))
       fields_for(object_name, *(args << options), &proc)
       concat('</form>')
     end
     alias_method :form_remote_for, :remote_form_for
                       
                       
                       
      class JavaScriptGenerator
        
        def initialize(context, &block) #:nodoc:
          @context, @lines = context, []
          include_helpers_from_context
          @context.instance_exec(self, &block)
        end
        
        private
          def include_helpers_from_context
            extend @context.helpers if @context.respond_to?(:helpers)
            extend GeneratorMethods
          end
          
          # JavaScriptGenerator generates blocks of JavaScript code that allow you 
          # to change the content and presentation of multiple DOM elements.  Use 
          # this in your Ajax response bodies, either in a <script> tag or as plain
          # JavaScript sent with a Content-type of "text/javascript".
          #
          # Create new instances with PrototypeHelper#update_page or with 
          # ActionController::Base#render, then call #insert_html, #replace_html, 
          # #remove, #show, #hide, #visual_effect, or any other of the built-in 
          # methods on the yielded generator in any order you like to modify the 
          # content and appearance of the current page. 
          #
          # Example:
          #
          #   update_page do |page|
          #     page.insert_html :bottom, 'list', "<li>#{@item.name}</li>"
          #     page.visual_effect :highlight, 'list'
          #     page.hide 'status-indicator', 'cancel-link'
          #   end
          # 
          # generates the following JavaScript:
          #
          #   new Insertion.Bottom("list", "<li>Some item</li>");
          #   new Effect.Highlight("list");
          #   ["status-indicator", "cancel-link"].each(Element.hide);
          #
          # Helper methods can be used in conjunction with JavaScriptGenerator.
          # When a helper method is called inside an update block on the +page+ 
          # object, that method will also have access to a +page+ object.
          # 
          # Example:
          #
          #   module ApplicationHelper
          #     def update_time
          #       page.replace_html 'time', Time.now.to_s(:db)
          #       page.visual_effect :highlight, 'time'
          #     end
          #   end
          #
          #   # Controller action
          #   def poll
          #     render(:update) { |page| page.update_time }
          #   end
          #
          # You can also use PrototypeHelper#update_page_tag instead of 
          # PrototypeHelper#update_page to wrap the generated JavaScript in a
          # <script> tag.
          module GeneratorMethods
            
            def to_s #:nodoc:
              returning javascript = @lines * $/ do
                if ActionView::Base.debug_rjs
                  source = javascript.dup
                  javascript.replace "try {\n#{source}\n} catch (e) "
                  javascript << "{ alert('RJS error:\\n\\n' + e.toString()); alert('#{source.gsub('\\','\0\0').gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }}'); throw e }"
                end
              end
            end
            
            # Insert an element (before, after) an other
            # NOTE : This method use mootools_patch.js
            def insert_html(position, id, *options_for_render)
              insertion = position.to_s.camelize
              call "$('#{id}').append#{insertion}", render(*options_for_render)
            end
            
            # Replace an element
            def replace(id, *options_for_render)
              assign "var text", render(*options_for_render)
              record "$('#{id}').replace(text)"
            end            
            
            # Replace the content of an element
            def replace_html(id, *options_for_render)
              assign "var text", render(*options_for_render)
              record "var scripts = \"\""
              record "var html = text.stripScripts(function(scr){scripts = scr;})"              
              record "$('#{id}').set('html',html)"
              record "$exec(scripts)"               
            end
            
            # Highlight an element
            def highlight(id, start_color='#FF8', end_color=nil)
              call("$('#{id}').highlight", *[start_color, end_color].compact)
            end
            
            # Shows hidden DOM elements with the given +ids+.
            def show(*ids)
              loop_on_multiple_args "setStyles({display:''})", ids
            end

            # Hides the visible DOM elements with the given +ids+.
            def hide(*ids)
              loop_on_multiple_args "setStyles({display:'none'})", ids
            end
            
            # Displays an alert dialog with the given +message+.
            def alert(message)
              call 'alert', message
            end
                        
            # Fire an event
            # TODO [mathieu] : with another element than 'window'
            def fire_event(event)
              call 'document.fireEvent', event
            end          
                        
            # Calls the JavaScript +function+, optionally with the given +arguments+.
            #
            # If a block is given, the block will be passed to a new JavaScriptGenerator;
            # the resulting JavaScript code will then be wrapped inside <tt>function() { ... }</tt> 
            # and passed as the called function's final argument.
            def call(function, *arguments, &block)
              record "#{function}(#{arguments_for_call(arguments, block)})"
            end

            # Assigns the JavaScript +variable+ the given +value+.
            def assign(variable, value)
              record "#{variable} = #{javascript_object_for(value)}"
            end
            
            def redirect_to(location)
              assign 'window.location.href', @context.url_for(location)
            end

            # Writes raw JavaScript to the page.
            def <<(javascript)
              @lines << javascript
            end

            # Executes the content of the block after a delay of +seconds+. Example:
            #
            #   page.delay(20) do
            #     page.visual_effect :fade, 'notice'
            #   end
            def delay(seconds = 1)
              record "setTimeout(function() {\n\n"
              yield
              record "}, #{(seconds * 1000).to_i})"
            end
            
            
            private
              def loop_on_multiple_args(method, ids)
                record(ids.size>1 ? 
                  "#{javascript_object_for(ids)}.each(function(element){$(element).#{method};})" : 
                  "$(#{ids.first.to_json}).#{method}")
              end
              
              def record(line)
                returning line = "#{line.to_s.chomp.gsub(/\;\z/, '')};" do
                  self << line
                end
              end
            
              def page
                self
              end
              
              def parse_transition_options(javascript_hash)
                javascript_hash.gsub(/(.*)transition: "(.*)"(.*)/,'\1transition: \2\3')
              end
              
              def render(*options_for_render)
                Hash === options_for_render.first ? 
                  @context.render(*options_for_render) : 
                    options_for_render.first.to_s
              end
              
              def javascript_object_for(object)
                object.respond_to?(:to_json) ? object.to_json : object.inspect
              end
              
              def arguments_for_call(arguments, block = nil)
                arguments << block_to_function(block) if block
                arguments.map { |argument| javascript_object_for(argument) }.join ', '
              end
            
              
              
              def block_to_function(block)
                generator = self.class.new(@context, &block)
                literal("function() { #{generator.to_s} }")
              end
              
              def method_missing(method, *arguments)
                JavaScriptProxy.new(self, method.to_s.camelize)
              end
          end # End GeneratorMethods
      end

      # Yields a JavaScriptGenerator and returns the generated JavaScript code.
      # Use this to update multiple elements on a page in an Ajax response.
      # See JavaScriptGenerator for more information.
      def update_page(&block)
        JavaScriptGenerator.new(@template, &block).to_s
      end

      def remote_function(options)
        javascript_options = options_for_ajax(options)

        request_type = options[:request_type].blank? ? "" : ".#{options[:request_type].to_s.upcase}"

        function = "new Request#{request_type}(#{javascript_options}).send()"
        function = "#{options[:before]}; #{function}" if options[:before]
        function = "#{function}; #{options[:after]}"  if options[:after]
        function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
        function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]

        return function
      end

      def form_remote_tag(options = {}, &block)
        options[:form] = true
        options[:data] = ""

        request_type = options[:request_type].blank? ? "" : ".#{options[:request_type].to_s.upcase}"
        
        options[:html] ||= {}
        options[:html][:onsubmit] = 
        (options[:html][:onsubmit] ? options[:html][:onsubmit] + "; " : "") + 
        "new Request#{request_type}($merge({data: $(this).toQueryString()}, #{options_for_ajax(options)})).send(); return false;"

        form_tag(options[:html].delete(:action) || url_for(options[:url]), options[:html], &block)
      end     

      def dom_ready(script=nil)
        js =  "window.addEvent('domready', function() {"
        js << script
        js << "});"
        js
      end

      def add_event(id, event, script=nil, &block)
        result = id.is_a?(Symbol) ? id.to_s : "$('#{id}')"
        result << ".addEvent('#{event}', function() {\n"
        result << (block_given? ? JavaScriptGenerator.new(@template, &block).to_s : script)
        result << "\n})"
        @controller.add_javascript(dom_ready(result))
        dom_ready(result)
      end

      protected
      
      def options_for_ajax(options)
        # FIXME (Did): callbacks are different from Prototype ones: before, we had: js_options = build_callbacks(options)
        js_options = {}

        url_options = options[:url]
        url_options = url_options.merge(:escape => false) if url_options.is_a?(Hash)
        js_options['url']          = "'#{url_for(url_options)}'"
        js_options['method']       = method_option_to_s(options[:method]) if options[:method]
        js_options['evalScripts']  = options[:script].nil? || options[:script]
        js_options['update']       = "$('#{options[:update]}')" if options[:update]
        js_options['onSuccess']    = "function(responseText, responseXML) { #{options[:success]} }" unless options[:success].blank?
        js_options['onRequest']    = "function() { #{options[:loading]} }" unless options[:loading].blank?
        js_options['onFailure']    = "function(args) { #{options[:failure]} }" unless options[:failure].blank?

        # actually, only for Request.HTML requests type.
        js_options['onComplete']   =  "function(responseTree, responseElements, responseHTML, responseJavaScript) { #{options[:complete]} }" unless options[:complete].blank?

        unless options[:form]
          if protect_against_forgery?
            if options[:data]
              js_options['data'] = "#{options[:data]} + '&' + "
            else
              js_options['data'] = ""
            end
            js_options['data'] << "'#{request_forgery_protection_token}=' + encodeURIComponent('#{escape_javascript form_authenticity_token}')"
          else
            js_options['data'] = "#{options[:data]}" unless options[:data].blank?
          end
        end

        options_for_javascript(js_options)
      end
      
      # DEPRECATED: should not be used (mootools callbacks different from Prototype ones)      
      def build_callbacks(options)
        callbacks = {}
        options.each do |callback, code|
          if CALLBACKS.include?(callback)
            name = 'on' + callback.to_s.capitalize
            callbacks[name] = "function(request){#{code}}"
          end
        end
        callbacks
      end
      
      def method_option_to_s(method) 
        (method.is_a?(String) and !method.index("'").nil?) ? method : "'#{method}'"
      end
    end
  end
end
