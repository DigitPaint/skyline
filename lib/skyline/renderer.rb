class Skyline::Renderer
  attr_reader :assigns, :template_paths
  attr_accessor :_config
  
  cattr_accessor :renderables
  @@renderables ||= {}
  
  @@renderables[:sections] = Skyline::Configuration.sections
  @@renderables[:articles] = %w{Skyline::Page} + Skyline::Configuration.articles
  
  class << self
    # The list of renderable classes by type
    #
    # ==== Parameters
    # type<Symbol>:: The type to get the renderable classes for
    # [sub<Symbol|Class>:: The sub class ie. :news_item or Skyline::Page when @@renderables[type] is an Hash]
    #
    # ==== Returns
    # Array[Class]:: Array of renderable classes
    #
    # --
    def renderables(type, sub = :all)
      @@renderables ||= {}
      
      if @@renderables[type].kind_of?(Hash)
        @@renderables[type] ||= {}
        if sub == :all
          @@renderables[type][:all] = renderables_to_class(type, @@renderables[type].values.flatten.uniq)
        else
          sub = sub.name.downcase.underscore.to_sym if sub.kind_of?(Class)
          classes = @@renderables[type][sub] || @@renderables[type][:default]
          @@renderables[type][sub] = renderables_to_class(type, classes)
        end
      else
        @@renderables[type] = renderables_to_class(type, @@renderables[type])
      end
    end

    # Add your own renderables
    def register_renderables(type, renderables)
      @@renderables[type] = renderables
    end
    
    # All availables renderable types
    def renderable_types
      @@renderables.keys
    end

    # Add a helper to the standard renderer
    #
    # ==== Parameters
    # module_name<~to_s,Module>:: Module/module name to include in the helper for renderer.
    #
    # --
    def helper(module_name)
      Helpers.helper(module_name)
    end   

    
    protected
    
    # Convert a renderable specified by string to a class
    def renderables_to_class(type, renderables)
      map = {:sections => "Skyline::Sections"}
      renderables.map{|f| f.kind_of?(String) ? "#{[map[type],f.camelize].compact.join("::")}".constantize : f}
    end
    
  end
  
  def initialize(options = {})
    options.reverse_merge!(:assigns => {}, 
                           :controller => nil, 
                           :paths => ["app/templates", Skyline.root + "app/templates/skyline"],
                           :page_version => nil,
                           :page_class => Skyline::Page,
                           :site => nil)

    @assigns = options[:assigns].update(:_controller => options[:controller], 
                                        :_site => options[:site],
                                        :page_class => options[:page_class])

    @template_paths = options[:paths].collect{|p| (Rails.root + p).to_s}
    @template_assigns = {}
  end
  
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
      
      self.assigns.merge(options[:assigns]).each do |k, v|
        av.assigns[k.to_sym] = v
      end

      av.assigns[:_assigns] = @template_assigns
      av.assigns[:_renderer] = self
      av.assigns[:_local_object_name] = object_config[:class_name].demodulize.underscore.to_sym
      av.assigns[:_local_object] = object
      
      av.extend RendererHelper
      av.extend Helpers
      
      av.render(:file => "index", :locals => options[:locals])
    end
  end
  
  def peek(n = 1)
    return [] if @_current_collection.blank?
    @_current_collection[@_current_collection_index + @_collection_skip + 1, n]
  end
  
  def peek_until(&block)
    return [] if @_current_collection.blank?
    peeking = []
    items = @_current_collection[@_current_collection_index + @_collection_skip + 1 .. -1]
    return [] unless items
    items.each do |i|
      return peeking if yield i
      skip!    
      peeking << i
    end
    peeking
  end
  
  def skip!(n = 1)
    return 0 if @_current_collection.blank?    
    @_collection_skip += n
  end
  
  def skip_until!(&block)
    return [] if @_current_collection.blank?
    items = @_current_collection[@_current_collection_index + @_collection_skip + 1 .. -1]
    return [] unless items
    item.each do |i|
      return if yield i
      skip!    
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
  # --
  def render_collection(objects, options = {}, &block)
    @_collection_skip = 0
    @_current_collection = objects
    output = []
    Array(objects).each_with_index do |object,i|
      
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
    
    output.join("\n")
  end
  
  # Returns a list of templates for a certain object or class. Raises an exception
  # if the class can't be found in the config.
  #
  # ==== Parameters
  # klass_or_obj<Class,Object>:: The instance / class to get the templates for.
  #
  # === Returns
  # Array:: An array with template names
  #
  # --
  def templates_for(klass_or_obj)
    klass = klass_or_obj.kind_of?(Class) ? klass_or_obj : klass_or_obj.class
    self.config[klass.name].andand[:templates] || []
  end
  
  def config
    return self._config if self._config && Rails.env == "production"
    
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
             }
    
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
  
  def templates_in_path(path)
    template_paths = []
    @template_paths.each do |root|
      Dir.chdir(root) do
        template_paths = template_paths | Dir.glob("#{path}/*").select{|d| File.directory?(d)  }.map{|d| File.basename(d)}
      end
    end
    template_paths
  end
  
  def object_config(object)
    object_config = self.config[object.class.name]
    raise ArgumentError, "Don't know how to render an object of class '#{object.class}'" unless object_config
    object_config.respond_to?(:call) ? object_config.call(object) : object_config
  end
  
  def object_template(object)
    object_config = self.object_config(object)
    
    template = object.section.template if object.respond_to?(:section)
    template = object.template if object.respond_to?(:template)
    template ||= "default"
    unless object_config[:templates].include?(template)
      Rails.logger.debug "Can find template '#{template}' for class '#{object.class}' so falling back to the default template. Available templates: #{object_config[:templates].inspect}"
      template = "default" 
    end
    template
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
  
    
  # The default Helpers module
  module Helpers
    include Skyline::Rendering::Helpers::ColumnHelper
    include Skyline::Rendering::Helpers::BreadCrumbHelper
    include Skyline::Rendering::Helpers::SettingsHelper    
    
    def helper(module_name)
      return self.send(:include,module_name) if module_name == Module
      
      module_name = module_name.to_s
      module_name << "_helper" if module_name !~ /_helper$/
      module_name = module_name.camelize
      module_name = "::#{module_name}" if module_name !~ /^::/
      self.send(:include,module_name.constantize)      
    end
    module_function :helper

    # Load all helpers
    Dir[Rails.root + "app/helpers/**/*_helper.rb"].each do |helper|
      self.helper helper.sub(Rails.root + "app/helpers/","").sub(/_helper\.rb$/,"")
    end  
    
  end
  
  module RendererHelper

    def assign(key, value = nil)
      return @_assigns[key] if value.nil?
      @_assigns[key] = value
    end
  
    def renderer
      @_renderer
    end
    
    def render_object(object, options = {})
      renderer.render(object, options)
    end
    
    def render_collection(objects, options = {},&block)
      renderer.render_collection(objects, options,&block)
    end
    
    def peek(n=1, &block)
      renderer.peek(n, &block)
    end
    
    def peek_until(&block)
      renderer.peek_until(&block)
    end
    
    def skip!(n=1)
      renderer.skip!(n)
    end

    def skip_until!(&block)
      renderer.skip_until!(&block)
    end
            
    def session
      @_controller.session
    end
    
    def params
      @_controller.params
    end
    
    def cookies
      @_controller.cookies
    end
    
    def request
      @_controller.request
    end
    
    def flash
      @_controller.flash
    end
    
    def site
      @_site
    end
    
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
    
    def protect_against_forgery?
      @_controller.send(:protect_against_forgery?)
    end
    
    def request_forgery_protection_token
      @_controller.request_forgery_protection_token
    end
    
    def form_authenticity_token
      @_controller.send(:form_authenticity_token)
    end
    
    # Simple, quick 'n dirty solution so you can use 'acticle_version', 'news_item', .. in all 
    # your templates. So you don't have to use @.... or pass the local to all partials.
    def method_missing(method, *params, &block)
      return @_local_object if @_local_object_name == method
      super
    end
  end  
end
