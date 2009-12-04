class Skyline::Article < ActiveRecord::Base
  class Data < ActiveRecord::Base
    self.abstract_class = true
    
    def self.inherited(subclass)
      super      
      subclass.set_table_name subclass.name.underscore.gsub("/","_")
      
      parent = subclass.parent
      parent.send(:belongs_to, :default_variant_data, :class_name => subclass.name)
      parent.send(:belongs_to, :published_publication_data, :class_name => subclass.name)
      
      ActiveSupport::Dependencies.autoloaded_constants << subclass.to_s if Rails.configuration.reload_plugins
    end

    ActiveSupport::Dependencies.autoloaded_constants << "Skyline::Article::Data" if Rails.configuration.reload_plugins
    
    has_one :version, :as => :data, :class_name => "Skyline::ArticleVersion"

    attr_accessor :to_be_published    
  end

  extend ActiveSupport::Memoizable

  set_table_name :skyline_articles
  
  # Associations
  has_many :versions, :class_name => "Skyline::ArticleVersion"
  has_many :variants, :class_name => "Skyline::Variant"
  has_many :publications, :class_name => "Skyline::Publication", :dependent => :destroy
  belongs_to :published_publication, :class_name => "Skyline::Publication"
  belongs_to :default_variant, :class_name => "Skyline::Variant"

  # Scopes
  named_scope :published, {:conditions => "published_publication_id IS NOT NULL"}  

  # Callbacks
  before_destroy :confirm_destroyability
  after_destroy :reset_ref_object
  after_destroy :destroy_variants

  # Validations
  validate :has_at_least_one_variant

  accepts_nested_attributes_for :variants

  attr_protected :locked unless Skyline::Configuration.enable_locking

  class << self
    def to_param
      self.name.underscore
    end
    
    # The prefix to use when determining rights. User#allow? uses
    # this method when called with 2 parameters.
    # --    
    def right_prefix
      "article"      
    end
    
    # used by SearchableItem
    def publishable?
      true
    end
  end

  def published?
    # Don't use only "self.published_publication" here, it causes way too many lookups
    # If the next test is wrong, than maybe you should wonder why it is wrong? Foreign key left behind?
    self.published_publication_id.present?
  end

  # Depublish a page, removes the published_publication if keep_history? is false
  # 
  # ==== Raises
  # StandardError:: if page is persistent
  # 
  # --
  def depublish
    raise StandardError, "can't be depublished because this page is persistent" if self.persistent?
    
    if self.published_publication
      self.published_publication.destroy unless self.keep_history?
      self.published_publication = nil
    end
    
    self.published_publication_data = nil
    self.url_part = "page-#{self.position}"
    
    self.save
  end
  
  def destroy
    depublish
    super
  end
  
  def depublishable?
    !self.persistent?
  end
  
  def destroyable?
    !self.persistent? && self.published_publication == nil
  end
  
  def renderable?
    self.renderable_scope.renderer.templates_for(self).any?
  end
  
  def renderable_scope
    Skyline::WildcardRenderableScope.new
  end
  
  def previewable?
    self.renderable?
  end
  
  def rollbackable?
    true
  end
  
  def keep_history?
    false
  end
  
  def enable_publishing?
    true
  end
  
  def enable_multiple_variants?
    true
  end
  
  def enable_locking?
    true
  end


  # Checks if the page can be edited by a certain user
  # Currently only checks on page locks.
  # --
  def editable_by?(user)
    user = user.kind_of?(Skyline::User) ? user : Skyline::User.find_by_id(user)    
    self.locked? && user.allow?(:page_lock) || !self.locked?
  end  

  def set_default_variant!(variant)
    return if variant.id == self.default_variant_id && variant.data_id == self.default_variant_data_id
    self.update_attributes(:default_variant_id => variant.id, :default_variant_data_id => variant.data_id)
  end
  
  def set_default_variant(variant)
    return if variant.id == self.default_variant_id && variant.data_id == self.default_variant_data_id
    self.attributes = {:default_variant_id => variant.id, :default_variant_data_id => variant.data_id}
  end  

  # The class that provides our custom data fields.
  # --
  # Note: We can't use memoize here, because it freezes the class
  def data_class
    return @_data_class unless @_data_class.nil?
    @_data_class = (self.class.name + "::" + "Data").constantize
  rescue NameError
    @_data_class = false
  end
  
  def right_prefix
    self.class.right_prefix
  end
  
  def title
    self.id
  end
  
  # a subclass might return a Page in which the article (ie: NewsItem) will be rendered for previewing
  def preview_wrapper_page
    nil
  end
  
  def sites
    [Skyline::Site.new]
  end
  
  def site
    Skyline::Site.new
  end  
  
  protected
  
  def after_initialize
    if self.new_record?
      v = self.variants.build(:article => self)
      self.default_variant_data = v.data
    end
  end
  
  def has_at_least_one_variant
    self.errors.add "must have at least one Variant" if self.variants.empty?
  end  

  
  def confirm_destroyability
    raise StandardError, "can't be destroyed because this page is persistent" if self.persistent?
  end  

  # reset ref objects that refer to removed media file
  # by setting referable_id = nil
  def reset_ref_object
    Skyline::RefObject.update_all({:referable_id => nil}, {:referable_id => self.id, :referable_type => self.class.name})    
  end  
  
  def destroy_variants
    self.variants.map(&:destroy_without_removing_page)
  end
end
