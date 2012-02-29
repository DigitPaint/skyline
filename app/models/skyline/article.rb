# Articles are container objects that contain Sections, have history and can (optional) be previewed
# and published.
#
# @abstract Subclass and implement the Article interface
class Skyline::Article < ActiveRecord::Base
  
  # The data object contains required structured data needed for an article.
  # 
  # @abstract Subclass and implement the Article::Data interface
  class Data < ActiveRecord::Base
    self.abstract_class = true
    
    def self.inherited(subclass)
      super      
      subclass.set_table_name subclass.name.underscore.gsub("/","_")
      
      parentclass = subclass.parent
      parentclass.class_eval do
        belongs_to :default_variant_data, :class_name => subclass.name
        belongs_to :published_publication_data, :class_name => subclass.name
      end
      
      subclass.class_eval do
        has_one :article, :foreign_key => "published_publication_data_id", :class_name => parentclass.name
        
        scope :published, {
          :include => [:article],
          :conditions => "skyline_articles.published_publication_data_id = #{self.table_name}.id"
        }
      end
      
      if !Rails.configuration.cache_classes && !(ActiveSupport::Dependencies.load_once_path?(__FILE__) && subclass.parents[-2] == ::Skyline)        
        ActiveSupport::Dependencies.autoloaded_constants << subclass.to_s
      end
    end

    unless ActiveSupport::Dependencies.load_once_path?(__FILE__)
      ActiveSupport::Dependencies.autoloaded_constants << "Skyline::Article::Data"
    end
    
    has_one :version, :as => :data, :class_name => "Skyline::ArticleVersion"

    attr_accessor :to_be_published    
  end

  extend ActiveSupport::Memoizable

  set_table_name :skyline_articles
  
  # Associations
  has_many :versions, :class_name => "Skyline::ArticleVersion" 
  # Variants well be destroyed in the after_destroy!! (Don't try to destro the versions!)
  has_many :variants, :class_name => "Skyline::Variant"
  has_many :publications, :class_name => "Skyline::Publication", :dependent => :destroy
  belongs_to :published_publication, :class_name => "Skyline::Publication"
  belongs_to :default_variant, :class_name => "Skyline::Variant"

  # Scopes
  scope :published, {:conditions => "published_publication_id IS NOT NULL"}  

  # Callbacks
  after_initialize :build_variant_with_data  
  after_save :set_default_variant_after_save
  before_destroy :confirm_destroyability
  after_destroy :reset_ref_object
  after_destroy :destroy_variants
  
  # Custom callbacks
  define_callbacks :publication
  define_callbacks :depublication

  # Validations
  validate :has_at_least_one_variant

  accepts_nested_attributes_for :variants

  attr_protected :locked unless Skyline::Configuration.enable_locking
  
  # Stores a variant that will become the default variant AFTER save
  attr_accessor :becomes_default_variant_after_save

  class << self
    def to_param
      self.name.underscore
    end
    
    # The prefix to use when determining rights. User#allow? uses
    # this method when called with 2 parameters.
    # 
    # @return [String] The string to prefix to the right (_create, _update, _delete)
    # @abstract Implement the value correct value in your subclass, defaults to 'article'
    def right_prefix
      "article"      
    end
    
    # Is this type of article publishable?
    # 
    # @return [true,false] Wether or not this article type can be published
    # @abstract Implement in subclass if needed, true is the default.
    def publishable?
      true
    end
    
    # Can this type of article be locked?
    #
    # @return [true,false] Wether or not this article type can be locked
    # @abstract Implement in subclass if needed, true is the default
    def lockable?
      true
    end
    
    # Can this type of article have multiple variants?
    #
    # @return [true,false]
    # @abstract Implement in subclass if needed, true is the default
    def can_have_multiple_variants?
      true
    end
    
  end

  # Has this article been puslished?
  #
  # @return [true,false] True if it has a published_publication, meaning it's currently published
  def published?
    # Don't use only "self.published_publication" here, it causes way too many lookups
    # If the next test is wrong, than maybe you should wonder why it is wrong? Foreign key left behind?
    self.published_publication_id.present?
  end

  # Depublish an article, removes the published_publication if keep_history? is false
  # 
  # @raise [StandardError] If page is persistent and cannot be depulished
  # @return [void] 
  def depublish
    raise StandardError, "can't be depublished because this page is persistent" if self.persistent?
    
    if self.published_publication
      self.run_callbacks :depublication do
        self.published_publication.destroy unless self.keep_history?
        self.published_publication = nil
      end
    end
    
    self.published_publication_data = nil
    self.url_part = "page-#{self.position}"
    
    self.save
  end
  
  # Depublish this article and destroy it.
  # 
  # @see Skylien::Article#depublish
  # @return [false,true] True sucessfully destroyed, otherwise false
  def destroy
    depublish
    super
  end
  
  # Can this article be depublished? 
  # 
  # @return [true,false]
  def depublishable?
    !self.persistent?
  end
  
  # Can this article be destroyed? Only works if the article isn't persisntent and does not have
  # a publication (isn't published).
  # 
  # @return [true,false]
  def destroyable?
    !self.persistent? && self.published_publication == nil
  end
  
  # Can this article be rendered. This basically means wether or not there are any templates for
  # this article.
  # 
  # @return [true,false]
  def renderable?
    self.renderable_scope.renderer.templates_for(self).any?
  end
  
  # Can this article be previewed? Delegates to Skyline::Article#renderable?
  #
  # @return [true,false]
  # @see Skyline::Article#renderable?
  def previewable?
    self.renderable?
  end
  
  # Can this article instance be locked? 
  # 
  # Defaults to the Skyline::Article.lockable?
  #
  # @see Skyline::Article.lockable?
  def lockable?
    self.class.lockable?
  end
  
  # Can this article instance have multiple variants?
  #
  # Defaults to Skyline::Article.can_have_multiple_variants?
  #
  # @see Skyline::Article.can_have_multiple_variants?
  def can_have_multiple_variants?
    self.class.can_have_multiple_variants?
  end

  # Do we need to keep the history of this article?
  # 
  # If true, this article will have multiple publications, if false, there is only one published publication.
  # 
  # @return [true, false] Default is false
  def keep_history?
    false
  end

  def dup
    s = super.tap do |dup|
      dup.created_at = nil
      dup.updated_at = nil
      dup.default_variant_id = nil
      dup.default_variant_data_id = nil
      dup.default_variant = nil
      dup.default_variant_data = nil
      dup.published_publication_id = nil
      dup.published_publication_data_id = nil
      
      dup.publications.clear
      dup.versions.clear
      dup.variants.clear
          
      self.variants.each do |variant| 
        variant_dup = variant.dup
        dup.variants << variant_dup
        variant_dup.article = dup
        variant_dup.article_id = nil
        self.becomes_default_variant_after_save = variant_dup if variant == self.default_variant
      end
      dup
    end
  end


  # Checks if the page can be edited by a certain user
  # Currently only checks on page locks.
  # 
  # @param user [Skyline::User,Integer] The user or user id to check the access for.
  # @return [true,false] True if the user can edit this page, false otherwise
  def editable_by?(user)
    user = user.kind_of?(Skyline::Configuration.user_class) ? user : Skyline::Configuration.user_class.find_by_identification(user)    
    self.locked? && user.allow?(:page_lock) || !self.locked?
  end  

  
  def set_default_variant!(variant)
    if set_default_variant(variant)
      self.save(:validate => false)
    end
  end
  
  def set_default_variant(variant)
    return false if variant.id == self.default_variant_id && variant.data_id == self.default_variant_data_id
    self.attributes = {:default_variant_id => variant.id, :default_variant_data_id => variant.data_id}
    true
  end  

  # The class that provides our custom data fields.
  # 
  # @return [Class,false] False if we don't have an inner Data class, the inner Data class if there is one.
  # 
  # TODO : Dataleak waiting to happen (!!)
  def data_class
    # Note: We can't use memoize here, because it freezes the class
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
  
  # A subclass can return a Page in which the article (ie: NewsItem) will be rendered for previewing
  # 
  # @return [Skyline::Page,nil] The page to wrap this article in when previewing. Nil if no wrapping is needed.
  # @abstract Implement this in a subclass to get the Page from Settings or from somewhere else.
  def preview_wrapper_page
    nil
  end
  
  # Multisite interface
  def sites
    [Skyline::Site.new]
  end
  
  # Multisite interface  
  def site
    Skyline::Site.new
  end  
  
  # Multisite interface  
  def renderable_scope
    Skyline::Rendering::Scopes::Wildcard.new
  end  
  
  protected
  
  def set_default_variant_after_save
    if self.becomes_default_variant_after_save && self.becomes_default_variant_after_save != self.default_variant
      self.set_default_variant!(self.becomes_default_variant_after_save)
      self.becomes_default_variant_after_save = nil
    end
  end
  
  def build_variant_with_data
    if self.new_record?
      v = self.variants.build(:article => self)
      self.default_variant_data = v.data
    end
  end
  
  def has_at_least_one_variant
    self.errors.add :variants, "must have at least one Variant" if self.variants.empty?
  end  

  
  def confirm_destroyability
    raise StandardError, "can't be destroyed because this article is persistent" if self.persistent?
  end  

  # Reset ref objects that refer to this now removed Article.
  # by setting referable_id = nil
  def reset_ref_object
    Skyline::RefObject.update_all({:referable_id => nil}, {:referable_id => self.id, :referable_type => self.class.name})    
  end  
  
  def destroy_variants
    self.variants.map(&:destroy_without_removing_page)
  end
end
