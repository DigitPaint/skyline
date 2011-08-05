module Skyline::Settings
  
  def self.included(obj)
    obj.extend(ClassMethods)
    obj.send(:serialize, :data)
  end  
  
  module ClassMethods
    
    # Define a page in the object, see example below
    #
    #  class DummyImplementation::Settings < DummyImplementation::ImplementationSettings
    #    page :general do |p|
    #      p.description "Here you can edit all your general settings"
    #      p.field :address, :type => :text
    #      p.field :newsletter, :type => :text    
    #      p.field :mission_statement, :type => :text
    #    end
    #    page :test do |p|
    #      p.description "A test of all possible options"
    #      p.field_group :name do |g|
    #        g.field :firstname, :type => :string
    #        g.field :lastname, :type => :string
    #      end
    #      p.field :birthdate, :type => :date
    #      p.field :today, :type => :datetime
    #      p.field :nr_of_kids, :type => :integer
    #      p.field :price_of_favourite_food, :type => :float
    #      p.field :loves_meat, :type => :boolean
    #    end    
    #  end
    def page(name,options={},&block)
      page = Skyline::Content::MetaData::FieldPage.new(self,name,options)
      yield(page)
      create_proxy_method(name)
      pages.update(name => page)
      page_order << page.name
      page
    end
  
    # The pages hash, access pages like this: Settings.pages[:name] to get the settingspage definition
    def pages
      @pages ||= {}
    end
      
    # The pages in order of page_order, returns an array of page objects.
    def ordered_pages
      page_order.map{|name| pages[name]}
    end
    
    # Return the page order as an array of page names
    def page_order
      @page_order ||= []
    end
    alias :page_names :page_order
    
    # We have to make sure always the same object will be retrieved
    # Do a forcefull reload if you want to get a new instance from the database
    def [](name)
      f = self.find(:first, :conditions => {:page => name.to_s})
      f ||= create(:page => name.to_s, :data => HashWithIndifferentAccess.new)
      f
    end
    
    # A safe way to get a value of a setting and report a warning if it can't be found  
    # instead of calling Setting[:setting_identifier].field directly use setting(:setting_identifier, :field)
    # 
    # @param setting_identifier [Symbol] the symbol of the settings page
    # @param field [Symbol] the name of the setting
    # 
    # @return [Object] the value of the setting or nil if not found
    def get(setting_identifier, field)
      if s = self[setting_identifier]
        if s.respond_to?(field)
          return s.send(field)
        end
      end
      Rails.logger.warn "Couldn't find Setting[:#{setting_identifier}].#{field}"
      nil
    end
    
    # a safe way to get a page from the settings  
    # 
    # @param setting_identifier [Symbol] the symbol of the settings page
    # @param field [Symbol] the name of the setting that references a page_id
    # 
    # @return [Page, NilClass] The page if found, nil otherwise
    def get_page(setting_identifier, field)
      if page_id = self.get(setting_identifier, field)
        return Skyline::Page.find_by_id(page_id) if page_id.present?
      end        
      nil
    end
    
    # Can be used to reference a Page/MediaFile etc directly. Sets it
    # to `FIELD_id`.
    # 
    # @param field [String,Symbol] The field name to use (multiple possible)
    def referable_serialized_content(*fields)
      fields.each do |f|
        self.class_eval <<-END
          def #{f}_attributes=(attr)
            self.#{f}_id = attr[:referable_id]
          end
        END
      end
    end    
    
    protected
    
    def page_cache
       @_page_cache ||= {}
    end
    
    def create_proxy_method(name)
      (class << self; self; end).send(:define_method,name){ self[name] }
    end    
  end
  
  # Set the data for this page, this works the same as .attributes= on 
  # regular ActiveRecord objects.
  def data=(data)
    data = HashWithIndifferentAccess.new(data)
    multi_parameter_attributes = [] 
    data.each do |k,v|
      k.include?("(") ? multi_parameter_attributes << [k,v] : send(k+"=",v)
    end
    assign_multiparameter_attributes(multi_parameter_attributes)
  end
  def data
    self[:data] ||= HashWithIndifferentAccess.new    
  end

  # Returns a hash before it was typecasted, is empty when we didn't set any data through
  # any virtual accessors yet.
  def data_before_type_cast
    @data_before_type_cast ||= HashWithIndifferentAccess.new
  end

  # Catch various virtual accessors and make sure xxx_before_typecast is also set.
  # Typecasts data on setting.
  def method_missing(meth,*args)
    base_method = meth.to_s.gsub(/(_before_type_cast)|(=)$/,"").to_sym
    if self[:page] && self.page && self.page.field_names.include?(base_method)
      field = self.page.fields[base_method.to_sym]
      case meth.to_s
        when /=$/ 
          self.data[base_method] = field.type_cast(args.first.blank? ? nil : args.first)
          self.data_before_type_cast[base_method] = args.first
        when /_before_type_cast$/ 
          self.data_before_type_cast[base_method]
        else self.data[base_method]
      end
    else 
      super
    end
  end
  
  # Analogue to method_missing
  def respond_to?(meth, include_private=false)
    s = super
    return s if s
    
    # Failsafe for stack level errors of calling _page from within AR read_attribute
    return false if meth == "_page"
    
    base_method = meth.to_s.gsub(/(_before_type_cast)|(=)$/,"").to_sym
    self[:page] && self.page && self.page.field_names.include?(base_method)
  end

  # The fields hash of the current settings-page
  def fields
    self.page.fields
  end

  # Returns the current settingspage. Every object instance can only
  # represent the data of one page.
  def page
    self.class.pages[(self.read_attribute_before_type_cast("page") || @attributes["page"]).to_sym]
  end      
    
  protected
  
  # Make sure we catch data fields first, this way we can make the multiparameter assignment work.
  # All other stuff is delegated to the superclass
  def column_for_attribute(name)
    return super if self.new_record? || self.class.column_names.include?(name)
    self.page.fields[name.to_sym]
  end
    
end