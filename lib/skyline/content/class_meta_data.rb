module Skyline::Content
  module ClassMetaData
    
    # Returns singular name of this class, falls back on standard Rails humanization
    def singular_name
      self.settings.singular_label
    end
    
    # Returns plural name of this class, falls back on standard Rails humanization    
    def plural_name
      self.settings.plural_label
    end
    
    # Is this a hidden class within the asked scope?
    # Currently scope is always :menu
    def hidden?(scope=:menu)
      self.settings.hidden == true || self.settings.hidden.kind_of?(Array) && self.settings.hidden.include?(scope)
    end
    
    
    # Returns the default_order_by_statement 
    def default_order_by_statement #:nodoc:
      self.settings.order_by || "id ASC"
    end  
      
    
    # General purpose method to set all kind of class options.
    # Works with hashes and blocks:
    #
    #   settings :label => ["label","labels"]
    #
    #   settings do |o|
    #     o.label = ["label","labels"]
    #   end    
    #
    # = Options available
    # <tt>label</tt>::   
    #   Parameters can be an array having 2 elements ["singular", "plural"] or just a string, in which 
    #   case it's assumed to be just singular.    
    # <tt>return_to_self_after_save</tt>::   
    #   Define wether or not after a save operation this object should return to itself
    #   or to the listview. Defaults to return to listview (false/nil)
    # <tt>identification_columns</tt>::   
    #   An array describing the columns this object can be described with, the values
    #   of these columns are joined with spaces. Parameter accepts also a single column name
    #   defaults to the first available of possible_identification_columns.
    # <tt>hidden</tt>::
    #   One or more of the following: [:menu] or just true for all of the aforementioned    
    # <tt>presenter</tt>::
    #   The presenter to use in the listview defaults to :table, only other option is
    #   :article at the moment. Use :article to make list orderable.
    # <tt>order_by</tt>::
    #   The default order of this model. Just a regular SQL order_by clause, can be a string or a symbol.
    # <tt>orderable</tt>::
    #   Make this object act as an orderable list. If set to true, model should contain a field named :position.
    #   Also, a hash can be passed of the form {:column => "position", :scope => :document}. In this case, articles that belong to
    #   a document can be sorted using their position to store order, and sorting will take place only within one document
    #
    # = Presenters
    # == Article
    # Displays a list with a Title and Subtitle and some fields (be warned this should be no more than 2 or 3).
    # The article presenter also alows drag and drop ordering if orderable is enabled.
    #
    # Extra options for the article presenter are:
    # <tt>title_field</tt>:: The field that should be used as a title in the list (defaults to first editable field if not specified)
    # <tt>subtitle_field</tt>:: The field that should be used as a subtitle in the list (defaults to nothing)
    #
    # == Table
    # The default table presenter. No extra options required.
    # -
    def settings(settings=nil,&block)
      return get_settings if settings.nil? && !block_given?
      s = MetaData::ClassSettings.new(settings.update(:owner => self))
      yield s if block_given?
      self.cmd_settings = s
      after_set_settings!
      s
    end
            
    protected
    
    def after_set_settings!
      if self.settings.orderable
        self.acts_as_orderable(self.settings.orderable)
      end
    end
    
    # @deprecated
    def sort_order(*sort_statements) # :nodoc:
      self.settings.order_by = sort_statements.map{|k| k.join(" ") }.join(",")
    end
    
    # Define wether this class should show up in a specific scope.
    # mostly used to hide classes in the CMS menu.
    #   hidden :in => :menu
    def hidden(options={}) #:nodoc:
      options.reverse_merge! :in => :menu
      self.settings.hidden = options[:in].kind_of?(Array) ? options[:in] : [options[:in]]
    end
    
    def get_settings
      self.cmd_settings = MetaData::ClassSettings.new(:owner => self) unless self.cmd_settings.present?
      self.cmd_settings
    end
  end
end