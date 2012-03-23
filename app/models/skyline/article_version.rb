# @private
class Skyline::ArticleVersion < ActiveRecord::Base
  self.table_name = "skyline_article_versions"
  
  belongs_to :article, :class_name => "Skyline::Article", :foreign_key => "article_id"
  belongs_to :data, :polymorphic => true, :dependent => :destroy, :inverse_of => :version
  belongs_to :creator, :class_name => "::#{Skyline::Configuration.user_class.name}"
  belongs_to :last_updated_by, :class_name => "::#{Skyline::Configuration.user_class.name}"
  has_many :sections, :class_name => "Skyline::Section", :dependent => :destroy
  
  validates_presence_of :name
  
  after_initialize :set_defaults  
  before_update :increase_version
  
  accepts_nested_attributes_for :data
  
  def build_data(*params, &block)
    attrs = params.first.dup
    raise ArgumentError, "Missing class parameter when building data" unless attrs["class"]
    klass = attrs.delete("class")
    self.data = klass.constantize.new(attrs)
  end

  def to_text  
    self.sections.collect{|s| s.to_text}.join(" ").squeeze(" ")
  end
  
  def dup
    super.tap do |dup|
      dup.created_at = nil
      dup.updated_at = nil
      dup.sections = self.sections.collect{|section| section.dup}
      dup.data = self.data.dup
    end
  end  
  
  # Clones this object and makes it have another class
  def dup_to_class(klass_or_proxy)
    dup = klass_or_proxy.build

    attrs = clone_attributes(:read_attribute_before_type_cast)
    attrs.delete(self.class.primary_key)
    attrs.delete("created_at")
    attrs.delete("updated_at")
    attrs["type"] = dup.type
    dup.send :instance_variable_set, '@attributes', attrs
    
    dup.variant = self if dup.respond_to?(:variant)  # only call clone.variant= for publications
    dup.sections = self.sections.collect{|section| section.dup}
    dup.data = self.data.dup
    dup
  end
  
  # Custom data method that ensures that you always have 
  # a data object if this article needs one.
  def data_with_build
    return self.data_without_build unless self.article  # article has been destroyed
    return self.data_without_build unless self.article.data_class
    if current_data = self.data_without_build
      return current_data
    else
      current_data = self.article.data_class.new 
      self.data = current_data unless self.frozen?
      return current_data
    end
  end
  alias_method_chain :data, :build

  def respond_to?(method, include_private = false)
    s = super
    return s if s
    method.to_s == self.article.class.name.demodulize.underscore
  end
  
  # Method missing implementation so we can call 
  # article_version.page to get the Page or article_version.xxx to get Xxx
  def method_missing(method,*params,&block)
    if method.to_s == self.article.class.name.demodulize.underscore
      self.article
    elsif method == :to_ary
      # this line fixes the to_ary problem
      raise NoMethodError
    else
      super
    end
  end
  
  def save_with_skip_version(*args)
    @_skip_version = true
    v = self.save(*args)
  ensure
    @_skip_version = false
    v
  end
  
  protected
  
  def set_defaults
    self.name = I18n.t(:default_name, :scope => [:page_version]) if self.name.blank?
    self.version ||= 1
  end
  
  def increase_version
    return if @_skip_version    
    self.version += 1
  end
  
end
