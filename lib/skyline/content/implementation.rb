# @private
class Skyline::Content::Implementation
  extend ActiveSupport::Memoizable
  include Singleton
  
  # All the content_classes. This works fine when using in Rails
  # as the implementation instance get's reloaded on each request. Make sure to reset
  # the cache if the classes change.
  def content_classes
    return @_contentclasses if @_contentclasses

    do_not_include = []
    @_contentclasses = Skyline::Configuration.content_classes.collect do |klass|
      klass = klass.kind_of?(Class) ? klass : klass.to_s.constantize
      if klass.respond_to?(:content?) && klass.content? && !klass.abstract_class
        klass.reflect_on_all_associations(:has_many).each do |assoc|
          # Do not include associated classes unless it's self-referential
          if assoc.klass && assoc.klass != klass && !assoc.through_reflection
            do_not_include << assoc.klass 
          end
        end
        klass              
      end
    end.compact
    @_contentclasses -= do_not_include
    
    Rails.logger.debug("Content constants: #{@_contentclasses.map{|c| c.to_s}.inspect}")    
    @_contentclasses
  end
    
  # Does this implementations have a Settings class?
  def has_settings?
    "Settings".constantize
    true
  rescue NameError
    false
  end
  memoize :has_settings?
  
  # The settings class for this implementation
  def settings
    "Settings".constantize if self.has_settings?
  end
  
  # Retrieve a content_class from the Implementation namespace by type
  # type can be a plural or a singular.
  def content_class(type)
    type_class_name = type.to_s.singularize.camelcase
    return if type_class_name.blank?
    content_class = type_class_name.constantize
    content_class if content_class.content? && !content_class.abstract_class
  rescue StandardError => e
    Rails.logger.warn("Failure while trying to get #{type_class_name} : #{e} #{e.backtrace.join("\n\t")}")
    nil
  end
  
end    
