# @private
class Skyline::ArticleVersion < ActiveRecord::Base
  set_table_name :skyline_article_versions
  
  belongs_to :article, :class_name => "Skyline::Article", :foreign_key => "article_id"
  belongs_to :data, :polymorphic => true, :dependent => :destroy
  belongs_to :creator, :class_name => "Skyline::User"
  belongs_to :last_updated_by, :class_name => "Skyline::User"
  has_many :sections, :class_name => "Skyline::Section", :dependent => :destroy
  
  validates_presence_of :name
  before_update :increase_version
  
  accepts_nested_attributes_for :data
  
  def build_data(data_attributes)
    params = data_attributes.dup
    raise ArgumentError, "Missing class parameter when building data" unless params["class"]
    klass = params.delete("class")
    self.data = klass.constantize.new(params)
  end

  def to_text  
    self.sections.collect{|s| s.to_text}.join(" ").squeeze(" ")
  end
  
  def clone
    returning super do |clone|
      clone.created_at = nil
      clone.updated_at = nil
      clone.sections = self.sections.collect{|section| section.clone}
      clone.data = self.data.clone
    end
  end  
  
  # Clones this object and makes it have another class
  def clone_to_class(klass_or_proxy)
    clone = klass_or_proxy.build

    attrs = clone_attributes(:read_attribute_before_type_cast)
    attrs.delete(self.class.primary_key)
    attrs.delete("created_at")
    attrs.delete("updated_at")
    attrs["type"] = clone.type
    clone.send :instance_variable_set, '@attributes', attrs
    
    clone.variant = self if clone.respond_to?(:variant)  # only call clone.variant= for publications
    clone.sections = self.sections.collect{|section| section.clone}
    clone.data = self.data.clone
    clone
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

  def respond_to?(method, include_priv = false)
    if method.to_s == self.article.class.name.demodulize.underscore
      self.article
    else
      super
    end
  end
  
  # Method missing implementation so we can call 
  # article_version.page to get the Page or article_version.xxx to get Xxx
  def method_missing(method,*params,&block)
    if method.to_s == self.article.class.name.demodulize.underscore
      self.article
    else
      super
    end
  end
    
  def save_with_skip_version(*args)
    @_skip_version = true
    v = self.save_without_skip_version(*args)
  ensure
    @_skip_version = false
    v
  end
  
  alias_method_chain :save, :skip_version
  
  
  protected
  
  def after_initialize
    self.name = I18n.t(:default_name, :scope => [:page_version]) if self.name.blank?
    self.version ||= 1
  end
  
  def increase_version
    return if @_skip_version
    self.version += 1
  end
end
