# @private
class Skyline::ArticleVersion < ActiveRecord::Base
  self.table_name = "skyline_article_versions"
  
  belongs_to :article, :class_name => "Skyline::Article", :foreign_key => "article_id"
  belongs_to :data, :polymorphic => true, :dependent => :destroy
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
  
  # Clones this object with another object and additional attributes
  #
  # @param [ArticleVersion] new_variant The variant to clone this object with
  # @param [Hash] attributes Additional attributes, they will be added as new objects. They can consist of:
  # @param [Hash] attributes[:data_attributes] data attributes, will be merged with this object's data
  # @param [Hash] attributes[:sections_attributes] Sections that need to be added. Note that both 'new' and 'updated' sections will be added as new objects
  # 
  # @return [ArticleVersion] A new variant that is a clone of this object
  def dup_variant_with(new_variant, attributes)
    dup_variant = self.dup
    dup_variant.sections = []
    
    # Equivalent to @variant.attributes = new_variant.attributes.except("version") without mass-assignment
    copy_attrs = %w{id type article_id variant_id name creator_id last_updated_by_id template created_at updated_at current_editor_id current_editor_timestamp current_editor_since data_id data_type}
    copy_attrs.each do |copy_attr|
      dup_variant.send("#{copy_attr}=", new_variant.send(copy_attr))
    end
    
    # Data should be updated for dup_variant, so it shouldn't use the original id
    dup_variant.data_attributes = attributes[:data_attributes].merge({:id => dup_variant.data_id})
    
    # Sections all need to be added as new, whether they are new or changed
    sections_attributes = attributes[:sections_attributes]
    new_sections_attributes = {}
    sections_attributes.each do |k, v|
      new_value = v
      if new_value[:id].present?
        orig_section_id = new_value.delete(:id)
        orig_section = Skyline::Section.find_by_id(orig_section_id)
        new_value[:sectionable_attributes].delete(:id)
        new_value[:sectionable_attributes][:class] = orig_section.sectionable_type
      end

      new_sections_attributes[k] = new_value
    end
    dup_variant.sections_attributes = new_sections_attributes

    dup_variant.id = new_variant.id
    
    dup_variant
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
