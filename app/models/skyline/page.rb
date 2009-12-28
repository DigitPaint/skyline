class Skyline::Page < Skyline::Article
  class Data < Skyline::Article::Data
    before_validation :sanitize_url_part
    validate :validate_url_part, :if => :to_be_published  
    validates_presence_of :title  

    def navigation_title
      self[:navigation_title].present? ? self[:navigation_title] : self.title.to_s
    end

    def title_tag
      self[:custom_title_tag].present? ? self[:custom_title_tag] : self.title
    end

    protected

    def after_initialize
      self.title ||= I18n.t(:default_title, :scope => [:page_version])    
    end

    def sanitize_url_part
      self.url_part = self.url_part.to_s.downcase.gsub(/[^a-z0-9\.\-\+_]/,"_").squeeze("_") if self.url_part
    end

    def validate_url_part
      return if self.version.article.root?
      if self.url_part.blank?
        self.errors.add :url_part, :blank 
      else
        if match = self.version.article.parent.children.find_by_url_part(self.url_part)
          self.errors.add :url_part, :taken  if match != self.version.article
        end
      end      
    end
  end
  
  include Skyline::Positionable
  self.positionable_scope = :parent_id
  
  has_many :children, :class_name => "Skyline::Page", :foreign_key => :parent_id, :dependent => :destroy
  belongs_to :parent, :class_name => "Skyline::Page", :foreign_key => :parent_id
      
  before_save :set_url_part
  after_save :process_move_behind
  
  validate :only_one_root
  
  named_scope :root_nodes, {:conditions => {:parent_id => nil}}
  named_scope :in_navigation, {:conditions => {:skyline_page_data => {:in_navigation => true}}, :include => [:published_publication_data]}
  named_scope :with_default_data, {:include => [:default_variant_data, :default_variant, :published_publication]}
  
  default_scope :order => "position"
 
  class << self
    extend ActiveSupport::Memoizable
    
    def right_prefix
      "page"
    end  
    
    # returns an Array of hashes
    #
    # ==== Returns
    # <Array[Hash]>:: Array of hashes grouped by parent_id
    def group_by_parent_id
      out = {}
      pages = self.connection.select_all("
        SELECT page.id,
               page.parent_id,
               data.navigation_title as navigation_title,
               data.title as title,
               page.locked,
               page.published_publication_id,
               page.default_variant_id,
               published_publication.variant_id AS published_publication_variant_id,
               published_publication.version AS published_publication_version,
               default_variant.version AS default_variant_version
        FROM #{self.table_name} AS page
        LEFT JOIN skyline_page_data AS data ON data.id=page.default_variant_data_id
        LEFT JOIN skyline_article_versions AS published_publication ON published_publication.id=page.published_publication_id
        LEFT JOIN skyline_article_versions AS default_variant ON default_variant.id=default_variant_id
        WHERE page.type='Skyline::Page'
        ORDER BY page.position")

      pages.each do |o|
        class << o
          def id; self["id"].to_i; end
          def parent_id; self["parent_id"].blank? ? nil : self["parent_id"].to_i; end
          def title
            if self["navigation_title"].blank?
              self["title"].blank? ? "n/a" : self["title"]
            else
              self["navigation_title"]
            end
          end
          def published?; self["published_publication_id"].present?; end
          def identical_to_publication?
            self["published_publication_variant_id"] == self["default_variant_id"] && self["published_publication_version"] == self["default_variant_version"]
          end
          def open; true; end
        end

        out[o.parent_id] ||= []
        out[o.parent_id] << o
      end
      out
    end
    
    def root
      self.find_by_parent_id(nil)
    end
    
    # build menu of certain level
    # ==== Parameters
    # level<Integer>:: level of the menu that has to be returned
    # nesting<Array>:: the nesting of page starting with the root node
    #
    # ==== Returns
    # <Array>:: an array of pages to display in the menu
    def menu(level = 1, nesting = nil)
      menu = []
      menu << {:page => self.root, :children => []} if level == 1 && self.root.in_navigation?
      nesting ||= [self.root]
      menu += nesting[level-1].menu if nesting[level-1]
      menu
    end
    
    def find_by_url(url_parts, root = nil)
      root ||= self.root
      return nil unless root
      return [root, []] if url_parts.empty?
      if child = root.children.find_by_url_part(url_parts.first)
        return self.find_by_url(url_parts[1..-1], child)
      end
      return [root, url_parts]
    end
    
  	def reorder(pages)
  		return unless pages.kind_of?(Array)
  		pages.each_with_index do |parent_id, position|
  			self.connection.execute("UPDATE #{self.table_name} SET position=#{position.to_i} WHERE id=#{parent_id.to_i}")
  		end  		
		end
	end
  
  def root?
    !self.parent
  end
  
  def nesting
    self.root? ? [self] : self.parent.nesting + [self]
  end
  memoize :nesting
  
  def parents
    self.nesting.dup[0..-2]
  end
  
  # Returns the path (url excluding current url_path), with trailing /
  # for the root page: nil
  # pages directly in the root: /
  # other pages, ie: /a/b/c/
  def path
    return nil if self.root?
    path = "/" + self.parents[1..-1].collect{|page| page.url_part}.join("/") + "/"
    path.squeeze("/")
  end
  
  def url
    return "/" if self.root?
    self.path + self.url_part
  end

  def menu
	  self.children.collect{|child| {:page => child, :children => child.menu} if child.published_publication_data.andand.in_navigation?}.compact
  end

  def destroyable?
    !self.persistent? && self.children.empty? && self.published_publication == nil
  end
  
  def keep_history?
    Skyline::Configuration.enable_publication_history
  end

    
  # create a new page on position
  # ==== Parameters
  # position<Symbol>:: Can either be :below, :above or :in
  #
  # ==== Returns
  # <Page>:: The new page
  def create_new!(position)
    page = Skyline::Page.new
    
    self.class.transaction do
	    case position
	  	when :below
	  		page.parent = self.parent
  			page.position = self.position + 1
  			self.class.connection.execute("UPDATE #{self.class.table_name} SET position=position+1 WHERE #{self.parent ? "parent_id=#{self.parent.id}" : 'parent_id IS NULL'} AND position>#{self.position}")
			when :above
				page.parent = self.parent
  			page.position = self.position
  			self.class.connection.execute("UPDATE #{self.class.table_name} SET position=position+1 WHERE #{self.parent ? "parent_id=#{self.parent.id}" : 'parent_id IS NULL'} AND position>=#{self.position}")
			when :in
				page.parent = self
			end    
			
			page.sites << self.site
			page.save
		end
		page
	end
  
	def move_behind=(parent_id)
	  @do_move_behind = true
	  @move_behind = parent_id
  end
    
  protected
  
  def process_move_behind
    if @do_move_behind
      if move_behind = self.class.find_by_id(@move_behind)
        self.class.connection.execute("UPDATE #{self.class.table_name} SET position=position+1 WHERE parent_id=#{self.parent_id} AND position > #{move_behind.position}")
        self.class.connection.execute("UPDATE #{self.class.table_name} SET position=#{move_behind.position + 1} WHERE id=#{self.id}")
      else
        self.class.connection.execute("UPDATE #{self.class.table_name} SET position=position+1 WHERE parent_id=#{self.parent_id}")
        self.class.connection.execute("UPDATE #{self.class.table_name} SET position=0 WHERE id=#{self.id}")
      end
      @do_move_behind = nil
      @move_behind= nil
    end
  end
  
  def set_url_part
    self.url_part = "page-#{self.position}" if self.url_part.blank?
  end

  def only_one_root
    if !self.parent && self.site
      if self.new_record?
        self.errors.add_to_base "cannot be another root node." if self.site.root
      else
        self.errors.add_to_base "cannot be another root node" if self.site.root && self.site.root.id != self.id
      end
    end
  end
  
  def confirm_destroyability
    raise StandardError, "can't be destroyed because this page has children" if self.children.any?
    super
  end  

end
