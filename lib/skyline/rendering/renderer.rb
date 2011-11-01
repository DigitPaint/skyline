# The skyline renderer renders all Articles, Sections and basically anything that's renderable
# or previewable in Skyline.
class Skyline::Rendering::Renderer
  attr_reader :assigns, :template_paths
  attr_accessor :_config
  
  cattr_accessor :renderables
  @@renderables ||= {}
  
  @@renderables[:sections] = Skyline::Configuration.sections
  @@renderables[:articles] = %w{Skyline::Page} + Skyline::Configuration.articles
  
  class << self
    # The list of renderable classes by type
    #
    # @param type [Symbol] The type to get the renderable classes for
    # @param sub [Symbol,Class] The sub class ie. :news_item or Skyline::Page when @@renderables[type] is an Hash]
    # 
    # @return [Array<Class>] Array of renderable classes
    def renderables(type, sub = :all)
      @@renderables ||= {}
      
      if @@renderables[type].kind_of?(Hash)
        @@renderables[type] ||= {}
        if sub == :all
          @@renderables[type][:all] = renderables_to_class(type, @@renderables[type].values.flatten.uniq)
        else
          sub = sub.name.underscore.to_sym if sub.kind_of?(Class)
          classes = @@renderables[type][sub] || @@renderables[type][:default]
          @@renderables[type][sub] = renderables_to_class(type, classes)
        end
      else
        @@renderables[type] = renderables_to_class(type, @@renderables[type])
      end
    end

    # Add your own renderables
    #
    # @param type [Symbol] The type (for instance `:sections` or `:articles`) to register your renderables under
    # @param renderables [Array<String,Symbol,Class>] Your own renderables
    def register_renderables(type, renderables)
      @@renderables[type] = renderables
    end
    
    # All availables renderable types
    #
    # @return [Array<Symbol>] All available types
    def renderable_types
      @@renderables.keys
    end

    # Add a helper to the standard renderer
    #
    # @param module_name [~to_s,Module>] Module/module name to include in the helper for renderer.
    def helper(module_name)
      Helpers.helper(module_name)
    end   

    
    protected
    
    # Convert a renderable specified by string to a class
    def renderables_to_class(type, renderables, additional_map = {})
      map = {:sections => "Skyline::Sections"}.merge(additional_map)
      renderables.map{|f| f.kind_of?(String) ? "#{[map[type], f.camelize].compact.join("::")}".constantize : f}
    end
    
  end
  
  # Creates a new renderer instance.
  #
  # @param options [Hash] Options
  #
  # @option options :assigns [Hash] ({}) Assigns to pass to the template, all assigns are accessible
  #   by their instance variable. `:test` becomes @test in the template.
  # @option options :controller [Controller] (nil) The controller that is serving the current request.
  # @option options :paths [Array<String,Pathname>]  (["app/templates", Skyline.root + "app/templates/skyline"])
  #   Paths that will be searched for templates.
  # @option options :site [Site] The currently active site object
  def initialize(options = {})
    options.reverse_merge!(:assigns => {}, 
                           :controller => nil, 
                           :paths => ["app/templates", Skyline.root + "app/templates/skyline"],
                           :site => nil)

    # The controller is optional!!
    @controller = options[:controller]
    @assigns = options[:assigns].update(:_controller => @controller, 
                                        :_site => options[:site])

    @template_paths = options[:paths].collect{|p| (Rails.root + p).to_s if File.exist?(Rails.root + p)}.compact
    @template_assigns = {}
  end
  
  # Render one renderable object
  # 
  # @param object [renderable] A renderable object
  # @param options [Hash] Options
  #
  # @option options :locals [Hash] ({}) Locals to make available to the template
  # @option options :assigns [Hash] ({}) Assigns merged with the global assigns of this renderer
  # 
  # @return [String] The rendered template
  def render(object, options = {})
    options.reverse_merge!(:locals => {}, :assigns => {})
    
    object_config = self.object_config(object)

    if object_config[:proxy]
      object_config[:proxy].call(self, object, options)
    else
      template = self.object_template(object)
      load_paths = self.object_template_paths(object)

      Rails.logger.debug "Rendering index template from paths: #{load_paths.join(', ')} (object.template = #{template})"

      av = ActionView::Base.new(load_paths.map(&:to_s))

      assigns = (options[:assigns] || {}).merge(self.assigns)
      assigns[:_template_assigns] = @template_assigns
      assigns[:_renderer] = self
      assigns[:_local_object_name] = object_config[:class_name].demodulize.underscore.to_sym
      assigns[:_local_object] = object
      
      av.assign(assigns)
      
      @_local_object = object   # for object function
      
      if @controller
        if @controller.respond_to?(:_routes)
          (class << av; self; end).send(:include, @controller._routes.url_helpers)
        end

        if @controller.respond_to?(:_helpers)
          (class << av; self; end).send(:include, @controller._helpers)
        end
      end
          
      av.extend Skyline::Rendering::Helpers::RendererHelper
      av.extend Helpers
      
      av.render(:file => "index", :locals => options[:locals]).html_safe
    end
  end
  
  
  
  # Render a collection of objects (array), this gives
  # support for peek() and skip!() in the templates. A template
  # can decide too look n items forward and skip n items because the template
  # itself rendered the next n items.
  #
  # By default each object is rendered with the default rendering options. If
  # you pass a block, this block is called for every item in the collection. The
  # return value of the block will be added to the output. No automatic rendering will be done.
  #
  # All assigns and template_assigns will be available to all (cloned) renderers. (This is
  # because clone only makes a shallow clone, attributes (like assigns) which are Hashes aren't copied:
  # a clone uses the same memory address of the attribute.)
  #
  # @param objects [Array<renderable>] An array of renderable objects.
  # @param options [Hash] Options will be passed to each consequent {Renderer#render} call.
  # 
  # @return [String] The rendererd templates
  def render_collection(objects, options = {}, &block)
    self.clone.send(:_render_collection, objects, options, &block)
  end
  
  # The current object that's being rendered
  #
  # @return [renderable] The renderable object.
  def object
    @_local_object
  end
  
  # Peek looks forward N position in the current renderable collection. Peek does not
  # modify the renderable collection.
  # 
  # Can only be used within a render_collection call. 
  # 
  # @param n [Integer] Number of items to look ahead
  # 
  # @return [Array<renderable>] N renderable items (or less if the collection end has been reached)
  def peek(n = 1)
    return [] if @_current_collection.blank?
    @_current_collection[@_current_collection_index + @_collection_skip + 1, n]
  end
  
  # Peek until the conditions in the passed block return true. Peek_until does not
  # modify the renderable collection.
  # 
  # Can only be used within a render_collection call. 
  # 
  # @yield [i] A block that must evaluate to true/false
  # @yieldparam i [renderable] The current renderable item
  # @yieldreturn [true,false] If true the collection from the entry point up until the
  #   moment the block returns true is returned as an array. If false the loop continues until
  #   the end of the collection is reached or the conditions in the block are met.
  # 
  # @return [Array<renderable>] Renderable items.
  def peek_until(&block)
    return [] if @_current_collection.blank?
    peeking = []
    items = @_current_collection[@_current_collection_index + @_collection_skip + 1 .. -1]
    return [] unless items
    items.each do |i|
      return peeking if yield i
      peeking << i
    end
    peeking
  end
  
  # Render_until does the same as peek_until but it also renders the objects
  # and advances the collection pointer until the conditions in the block are met.
  # 
  # @see peek_until
  def render_until(&block)
    peek_until(&block).collect{|i| self.skip!; self.render(i)}.join
  end
  
  # Advances the collection pointer by one
  # 
  # Can only be used within a render_collection call.
  # 
  # @param n [Integer] Number of items to skip
  def skip!(n = 1)
    return 0 if @_current_collection.blank?    
    @_collection_skip += n
  end
  
  # Skip_until! works like peek_until except it skips until the conditions
  # in the passed block are met.
  # 
  # @see peek_until
  def skip_until!(&block)
    return [] if @_current_collection.blank?
    items = @_current_collection[@_current_collection_index + @_collection_skip + 1 .. -1]
    return [] unless items
    items.each do |i|
      return if yield i
      skip!    
    end
  end
  
  # Returns a list of templates for a certain object or class. Raises an exception
  # if the class can't be found in the config.
  #
  # @param klass_or_obj [Class,Object] The instance / class to get the templates for.
  #
  # @return [Array] An array with template names
  def templates_for(klass_or_obj)
    klass = klass_or_obj.kind_of?(Class) ? klass_or_obj : klass_or_obj.class
    self.config[klass.name].andand[:templates] || []
  end
  
  # The current rendering configuration
  # 
  # @param options [Hash] Options
  #
  # @option options :additional_config [Hash] ({}) An additional config to use just for 
  #   this instance of the renderer. Setting :additional_config updates the config!
  # 
  # @return [Hash] the current config
  # 
  # @todo Check the exact syntax of options and what happens with the parameters of the :proxy.
  #   blocks.
  def config(options = {})
    return self._config if self._config && Rails.env == "production"
    options.reverse_merge!(:additional_config => {})
    
    delegate_proc = Proc.new do |object| 
      {
        :class_name => "Skyline::ArticleVersion", 
        :path => object.article.class.name.sub(/^Skyline::/, '').underscore,
        :templates => self._config[object.article.class.name].andand[:templates] || []
      }
    end
    
    config = {"Skyline::Variant"      => delegate_proc,
              "Skyline::Publication"  => delegate_proc,
              "Skyline::Section"      => {:proxy => Proc.new{|renderer, section, options| renderer.render(section.sectionable, options)}},
             }.merge(options[:additional_config])
    
    self.class.renderable_types.each do |type|
      self.class.renderables(type).each do |renderable|
        name = renderable.name
        config[name] = {:class_name => name }
      end
    end

    config.each do |object, object_config|
      if object_config.kind_of?(Hash) && !object_config[:proxy]
        object_config[:path] ||= object_config[:class_name].sub(/^Skyline::/, '').underscore
        object_config[:templates] = templates_in_path(object_config[:path])
        object_config[:templates].sort!
      end
    end
    
    self._config = config
  end
  
  def object_template_paths(object)
    object_config = self.object_config(object)
    template = self.object_template(object)
    
    template_path = object_config[:path]
    path = "#{template_path}/#{template}"
    default_path = "#{template_path}/default"

    load_paths = []
    load_paths += @template_paths.collect{|p| File.join(p, path)}
    load_paths += @template_paths.collect{|p| File.join(p, template_path)}
    load_paths += @template_paths.collect{|p| File.join(p, default_path)} unless template == "default"
    load_paths
  end

  def file_path(object, filename)
    paths = object_template_paths(object)
    paths.each do |path|
      return File.join(path, filename) if File.exists?(File.join(path, filename))
    end
    nil
  end
  
  protected
  
  def object_config(object)
    object_config = self.config[object.class.name]
    raise ArgumentError, "Don't know how to render an object of class '#{object.class}'" unless object_config
    object_config.respond_to?(:call) ? object_config.call(object) : object_config
  end
  
  def object_template(object, template = nil)
    object_config = self.object_config(object)
    
    template ||= object.template if object.respond_to?(:template)
    template ||= object.section.template if object.respond_to?(:section)
    template ||= "default"
    unless object_config[:templates].include?(template)
      Rails.logger.debug "Can find template '#{template}' for class '#{object.class}' so falling back to the default template. Available templates: #{object_config[:templates].inspect}"
      template = "default" 
    end
    template
  end

  def templates_in_path(path)
    template_paths = []
    @template_paths.each do |root|
      Dir.chdir(root) do
        template_paths = template_paths | Dir.glob("#{path}/*/index.*").map{|d| File.dirname(d) }.select{|d| File.directory?(d)  }.map{|d| File.basename(d)}
      end
    end
    template_paths
  end  
  
  # Do not use this method directly. Instead use the render_collection method.
  # This is because nested calls to render_collection will fail due to shared
  #   variables (like @_current_collection).
  def _render_collection(objects, options = {}, &block)
    @_collection_skip = 0
    @_current_collection = objects
    output = []
    Array(objects).each_with_index do |object, i|
      
      if @_collection_skip > 0
        @_collection_skip -= 1
        next
      end
      
      @_current_collection_index = i
      if block_given?
        output << yield(object)
      else
        output << self.render(object, options)
      end
    end    
    @_current_colection = nil
    
    output.join("\n").html_safe
  end  
  
    
  # The default Helpers module
  module Helpers
    include Skyline::Rendering::Helpers::ColumnHelper
    include Skyline::Rendering::Helpers::BreadCrumbHelper
    
    def helper(module_name)
      return self.send(:include,module_name) if module_name == Module
      
      module_name = module_name.to_s
      module_name << "_helper" if module_name !~ /_helper$/
      module_name = module_name.camelize
      module_name = "::#{module_name}" if module_name !~ /^::/
      self.send(:include, module_name.constantize)      
    end
    module_function :helper

    # Load all helpers
    Dir[Rails.root + "app/helpers/**/*_helper.rb"].each do |helper|
      self.helper helper.sub(/^#{Regexp.escape((Rails.root + "app/helpers/").to_s)}/,"").sub(/_helper\.rb$/,"")
    end  
    
  end
end
