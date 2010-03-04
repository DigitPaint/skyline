class Skyline::Variant < Skyline::ArticleVersion
  include NestedAttributesPositioning
  
  belongs_to :current_editor, :class_name => "Skyline::User"
  
  validate :validate_version_match
  
  accepts_nested_attributes_for :sections, :allow_destroy => true 
  
  before_create :create_data
  before_destroy :confirm_destroyability
  after_save :update_article_default_variant
  after_destroy :update_article_default_variant_on_destroy
  
  default_scope :order => "updated_at DESC"
  
  class << self
    def find_current_editor_for(id)
      values = self.connection.select_one("SELECT current_editor_id,current_editor_timestamp, current_editor_since FROM #{self.table_name} WHERE id = #{id.to_i}")
      %w{current_editor_timestamp current_editor_since}.each do |t|
        values[t] = ActiveRecord::ConnectionAdapters::Column.string_to_time(values[t]) if values[t]
      end
      values
    end
    
    # Updates the current editor timestamp for a variant
    #
    # ==== Parameters
    # id<Integer>:: The ID of the variant
    # editor_id<Integer>:: The id of the current editor
    #
    # ==== Options
    # :new_editor<Boolean>:: If true, we also set "current_editor_since"
    # :force<Boolean>:: Force the takeover, this wil update the version number and render all other editors editing this page unusable (default = false)
    def update_current_editor(id, editor_id, options={})
      options.reverse_merge! :new_editor => false, :force => false
      values = {:current_editor_id => editor_id, :current_editor_timestamp => Time.zone.now.utc}
      values[:current_editor_since] = Time.zone.now.utc if options[:new_editor]
      extra_sql = ""
      extra_sql << ", version = version + 1" if options[:force]
      
      self.connection.update("UPDATE #{self.table_name} SET #{ sanitize_sql_for_assignment(values) }#{extra_sql} WHERE id = #{id.to_i}")
    end
    
    def editor_idle_time
      30
    end    
  end  
  
  def publish
    self.prepare_data_to_be_published!(true)
    
    raise StandardError, "can't be published if its dirty" if self.changed? || self.data.changed?
    
    if self.valid?
      self.prepare_data_to_be_published!(false)

      published_publication = self.clone_to_class(self.article.publications)
      published_publication.save

      self.article.published_publication = published_publication
      self.article.url_part = published_publication.data.url_part if published_publication.data.respond_to?(:url_part)
      self.article.published_publication_data = published_publication.data
      self.article.set_default_variant(self)
      self.article.save!

      unless self.article.keep_history?
        self.article.publications.each do |publication|
          publication.destroy if publication != published_publication
        end
      end

      published_publication
    else
      self.prepare_data_to_be_published!(false)
      false
    end
  end
  
  def prepare_data_to_be_published!(value = true)
    self.data.to_be_published = value if self.data.respond_to?(:to_be_published=)
  end
  
  # ==== Options
  # :article<Article>:: If you've already loaded the article somewhere else, you can pass it  
  def published_variant?(options = {})
    options.reverse_merge! :article => self.article
    options[:article].published_publication.andand.variant_id == self.id
  end
  
  # ==== Options
  # :article<Article>:: If you've already loaded the article somewhere else, you can pass it
  def identical_published_variant?(options = {})
    options.reverse_merge! :article => self.article
    self.published_variant?(options) && self.version == options[:article].published_publication.version
  end
  
  # Check wether or not this page is editable by user
  # Checks the following:
  #  * page.locked?
  #  * Skyline::Configuration.enable_enforce_only_one_user_editing
  #  * currently_editable_by?
  #
  # ==== Parameters
  # user<User,Integer>:: A user instance or a user id
  #
  # ==== Returns
  # true,false:: true if the user is allowed to edit.
  def editable_by?(user)
    user_id = user.kind_of?(Skyline::User) ? user.id : user
    return true unless Skyline::Configuration.enable_enforce_only_one_user_editing
    self.current_editor_id.nil? || self.current_editor_timestamp.nil? || self.current_editor_id == user_id || self.class.editor_idle_time < (Time.zone.now - self.current_editor_timestamp)
  end
  
  # Set a new user that will be editing this page.
  #
  # ==== Parameters
  # user<User,Integer>:: A user instacne or a user id
  # 
  # ==== Options
  # :force<Boolean>:: Force the takeover, this wil update the version number and render all other editors editing this page unusable (default = false)
  def edit_by!(user, options = {})
    options.reverse_merge! :force => false
    options[:new_editor] = true
    user_id = user.kind_of?(Skyline::User) ? user.id : user
    self.class.update_current_editor(self.id, user_id, options)
  end
  
  def destroyable?
    if self.article.andand.published_publication
      self.article.published_publication.variant != self
    else
      # also yield true if self.article doesn't exist (this happens when the article is already destroyed)
      true
    end
  end
  
  def destroy_with_removing_page
    self.destroy_without_removing_page
    self.article.destroy if self.article.variants(true).empty?
  end
  alias_method_chain :destroy, :removing_page

  protected
  def confirm_destroyability
    raise StandardError, "Can't be destroyed if the published publication is based on this variant" unless self.destroyable?
  end
  
  def validate_version_match
    self.errors.add :version, :outdated if self.version_changed? && self.version_change.first > self.version_change.last
  end
  
  def create_data
    if self.data.new_record?
      self.data.save(false)
      self.data_id = self.data.id
    end
  end
  
  def update_article_default_variant
    self.article.set_default_variant!(self) 
  end
  
  def update_article_default_variant_on_destroy
    # when the article is gone (deleted) return silently
    return unless self.article
    
    # when this variant is destroyed and the article isn't published, make the first variant (that's left) the default
    if !self.article.published? && self.article.variants.any?
      self.article.set_default_variant!(self.article.variants.first) 
    end
  end
end
