module Skyline::Content
  module FieldMetaData
    # General purpose method to set all kind of field options.
    # Works with hashes and blocks:
    #   field :description, :editor => :wysiwyg
    #
    #   field :description,:location_information do |o|
    #    o.editor = :wysiwyg
    #   end    
    #
    # === Common options
    # <tt>editor</tt>::  
    #   Defines the type of editor this field should be editted with, see below
    #   for a more detailed description and possible options per editor.
    # <tt>label</tt>::   
    #   The label to be used for this field when it's editted: for checkboxes this will be the text
    #   that's displayed just after the checkbox, use <tt>title</tt> to change the text above the checkbox.
    #   Parameters can be an array having 2 elements ["singular", "plural"] or just a string, in which 
    #   case it's assumed to be just singular.
    # <tt>description</tt>::
    #   Set a description for this field, it's usually displayed just below the title.
    # <tt>hidden</tt>::
    #   One or more of the following: [:list, :create, :edit] or just true for all of the aforementioned
    # <tt>title</tt>::
    #   The title will be used in the list, and as a title for checkboxes. The title will mostly be the same
    #   as the label, which it's defaults from. Title accepts same parameters as label
    # <tt>prefix</tt>::
    #   This is the text that will be placed before the actual inputfield, can also be a proc so you can do:
    #     field :url, :prefix => Proc.new{|owner| owner.parent.url }
    #   Needless to say, this works only in the edit/create forms, not in the list.
    # <tt>suffix</tt>::
    #   Same as prefix but after the input field.
    # <tt>filter_html</tt>::
    #   This affects filtering of HTML tags in the list views. Defaults to true, if set to false it will not filter
    #   Any HTML tag. *warning* : This will probably change in a later version!
    # <tt>filterable</tt>::
    #   Make this model filterable on this field, this only works with true database fields or belongs_to association
    #   fields. It will raise an ArgumentError if a database field cannot be found.
    #
    # 
    # == Editors
    # === Textarea
    # Renders a standard textarea tag.
    # 
    # <tt>style</tt>::
    #   Gives a style tag to the textarea element, use hashlike notation: {:height => 14} for "height: 14px"    
    #
    # === Date
    # The standard editor for date_time types.
    #
    # <tt>year_options</tt>::
    #   Options to pass to the rails year_select helper, for instance: {:start_year => 1990, :end_year => Time.now.year + 5}
    #
    # === Text_field
    # Renders a standard input text field tag.
    #
    # <tt>style</tt>::
    #   Gives a style tag to the textarea element, use hashlike notation: {:height => 14} for "height: 14px"    
    #
    # === Wysiwyg
    # Creates a wysywig editor for editting bigger texts
    #
    # <tt>style</tt>::
    #   Gives a style tag to the textarea element, use hashlike notation: {:height => 14} for "height: 14px"    
    # <tt>tinymce_options</tt>::
    #   A hash with tinymce specific options. See tinyMCE documentation for more information. The hash will be converted
    #   to a javscript hash, so {:theme => "simple", :plugins => ["a","b"]} will become "{theme:'simple', plugins:'a,b'}". Warning:
    #   do not override mode and elements keys, they will not be included in the tinymce settings.
    # <tt>image_classes</tt>::
    #   Shortcut for tinymce_options[:skylineimage_classes], a Hash describing classes images can have, key is the classname, value is the description.
    # <tt>link_classes</tt>::
    #   Shortcut for tinymce_options[:advlink_styles], a Hash describing classes links can have, key is the classname, value is the description.
    # <tt>blockformats</tt>::
    #   Shortcut for tinymce_options[:theme_advanced_blockformats], a Hash description block elements, key is the element, value is description, can also
    #   be an array of block elements.
    # <tt>template</tt>::
    #   A full set of tinymce options, including buttons etc. Currently only :standard (the default) and :email (a stripped
    #   down version with only B/I/U/Link buttons in the toolbar) are available
    # 
    # === Textile
    # Same as wywisywg but yields a regular textarea with a preview of the markup next to it.
    #
    # <tt>style</tt>:: 
    #   Gives a style tag to the textarea element, use hashlike notation: {:height => 14} for "height: 14px"
    # <tt>cache</tt>::
    #   Cache defaults to true and uses <tt>field_name</tt>_html. It also sets :hidden => true for these 
    #   cache fields. Warning: this does not do the actual textile transformation, you still need to do that yoruself.
    # 
    # === Display
    # Doesn't display an actual editor, just the value
    #
    # <tt>blank</tt>:: The value that should be displayed when the field would have a nil value.
    # 
    # === Heading
    # Displays the field as a bigger and bold textbox.    
    #
    # <tt>style</tt>::
    #   Gives a style tag to the textarea element, use hashlike notation: {:height => 14} for "height: 14px"    
    # 
    # === List
    # Makes the choice a dropdown box, needs the option :list to be set.
    #
    # <tt>list</tt>::
    #   Accepts a proc which returns a list or just a regulur array. See the examples below for more info.
    # 
    # Example:
    #  field :events, :editor => :list, :list => [["Letter A","a"],["Second Letter","b"]]
    #  field :events, :editor => :list, :list => Proc.new{|owner| owner.events.collect{|e| [e.name,e.id]}}
    #
    # The above is short for:
    #   field :events do |o|
    #     o.editor = :list
    #     o.list = Proc.new{|owner| owner.events.collect{|e| [e.name,e.id]} }
    #   end
    # 
    # === Inline List
    # Only works with has_many associations. Will show the list below the save button on the edit screen.
    # Using a collection as an inline field will also remove it from the display in the list view of the 
    # parent class.
    # 
    # <tt>presenter</tt>::
    #   The presenter to use for the display list. (See also: Skyline::Content::ClassMetaData)
    # 
    # === Editable List
    # Only works with has_many associations. It's best suited for editing of small items like
    # agenda items. The list will appear inline and will save ONLY when the main object is saved. For
    # every added item a new sub-form will be created. Items can be deleted but won't actually be removed
    # before the main object is saved.
    #    
    # === Joinable List
    # Makes inline joins possible for <tt>has_and_belongs_to_many</tt> relations and also for <tt>has_many :through => ""</tt>
    # relations. Joinabe list is also the default editor for has_and_belongs_to_many if no editor is specified.
    #
    # <tt>default_filter</tt>::
    #   Proc (in the format Proc.new{|owner| {:filter_field => owner.foreign_key}}) or a hash in the format
    #   {:filter_field => "value"}. This filter will be applied on the list.
    # 
    # === Checkable List
    # The checkable list works with has_and_belongs_to_many relations. It renders
    # a list of the related objects with checkboxes in front of them. All checked objects
    # will be related.
    #
    # === File browser
    # The file_browser editor allows you to select files from the media_library. They will
    # be added through a RefObject.
    # 
    # === Page browser
    # The page_browser editor allows you to select pages from the Pages in Skyline. They will
    # be added through a RefObject.
    # 
    #--
    def field(*fields,&block)
      options = options_from_params_with_default fields      
      fields = fields.first if fields.any? && fields.first.kind_of?(Array)
      options.reverse_merge! field_create_defaults(options)
      
      fields.each do |field_name|
        options.update(:name => field_name, :owner => self)
        if self.fields.has_key?(field_name)
          self.fmd_field_hash = self.fields.merge(field_name => MetaData::Field.from(self.fields[field_name],options))
        else
          self.fmd_field_hash = self.fields.merge(field_name => MetaData::Field.new(options))
        end
        self.fmd_ungrouped_field_list = self.ungrouped_fields << field_name
        yield self.fields[field_name] if block_given?
        after_field_create!(self.fields[field_name])
      end
      fields.map{|f| self.fields[f]}
    end
    
    # @deprecated
    alias :field_options_for :field #:nodoc:
    
    # Group fields together into a fieldgroup.  
    #   field_group :naw, :title => "Naam, adres en woonplaats" do |g|
    #     g.field :name, :editor => :heading
    #     g.field :address
    #     g.field :city, :label => "Woonplaats"
    #   end
    #--
    def field_group(name,options={})
      options.reverse_merge! :fields => [], :title => name.to_s.humanize, :type => nil
  
      field_group = MetaData::FieldGroup.new(options.update(:owner => self, :name => name))
      yield field_group if block_given?
      
      self.fmd_ungrouped_field_list = self.ungrouped_fields.dup << name
      self.fmd_field_hash = self.fields.merge(name => field_group)
      
      field_group
    end
    
    # Order the fields (also works with field groups)
    #   field_order :name,:naw,:body
    def field_order(*order)
      if order.empty?
        self.fmd_field_order_value = order unless self.fmd_field_order_value.present?
        self.fmd_field_order_value
      else
        self.fmd_field_order_value = order
      end
    end
    
    # All directly writable fields. This includes all defined fields except fields:
    # * with editor "display" because these aren't editable anyway
    # * which are associations, as they would not appear in the form
    # * which are hidden in the edit screen (although, they can still be hidden in the create screen)
    # 
    # ==== Returns
    # <tt>Array[Symbol]</tt>:: Field names of fields which are writable.
    #--
    def writable_fields #:nodoc:
      self.fields.select do |k,v|
        if v.kind_of?(MetaData::Field) && v.editor == :file && !v.hidden_in(:edit)
          true
        else
          !v.kind_of?(MetaData::FieldGroup) &&
          ![:display].include?(v.editor) && 
          !v.hidden_in(:edit) && 
          !v.association?
        end
      end.map{|k,v| k}
    end
    
    # All fields that can be used for filtering
    # 
    # ==== Returns
    # <tt>Array[Symbol]</tt>:: An array of fieldnames which can be used in filtering.
    #--
    def filterable_fields #:nodoc:
      self.fields.select{|k,v| v.kind_of?(MetaData::Field) && v.filterable }.map{|k,v| k}
    end
    
    def fields #:nodoc:
      self.fmd_field_hash || {}
    end
            
    def ungrouped_fields #:nodoc:
      self.fmd_ungrouped_field_list || []
    end
    
    # @deprecated
    def association_fields #:nodoc:
      if self.respond_to?(:reflect_on_all_associations)
    		@assoc_names ||= self.reflect_on_all_associations().collect{|assoc| assoc.name} 
    	else
    	  []
    	end
    end
    
    # @deprecated
    def hidden_columns #:nodoc:
      [:published, :position]
    end
    
    # @deprecated
    def non_hidden_columns #:nodoc:
      return [] if !self.table_exists?
      self.content_columns.map{|col| col.name.to_sym} - self.hidden_columns
    end
    
        
    # Yields all fields in order (also the columns not specified in field_order)    
    def each_field(&block) #:nodoc:  
      self.field_names.each do |field_name|
        yield_field(field_name, &block)
      end      
    end    
    
    def only_each_field_of(selection,&block) #:nodoc:
      selection.each do |field_name|
        if self.field_names.include?(field_name)          
          yield_field(field_name,&block)
        else
          yield nil
        end
      end
    end
    
    # Array of all fields in order (also the columns not specified in @@field_order)
    def field_names #:nodoc:
      get_field_names.uniq      
    end
    
    private   
    
    # Defaults for different field types.
    #--
    def field_create_defaults(options)
      case options[:editor]
        when :textile then {:cache => true} 
        when :inline_list then {:hidden => [:list,:create]}
        else {}
      end
    end
    
    # Callback after a field is created, add special options that needs to be invoked based
    # on the field meta data here.
    #-- 
    def after_field_create!(field)
      case field.editor
        when :textile
          self.field("#{field.attribute_name}_html".to_sym, :hidden => true) if field.cache
        when :inline_list 
          self.settings.return_to_self_after_save = true
        when :joinable_list, :editable_list, :checkable_list
          alias_method "original_#{field.attribute_name}=", "#{field.attribute_name}="
          define_method("#{field.attribute_name}=") do |values|
            process_related_objects(field,values)
          end
      end      
    end
        
    def options_from_params_with_default(params,default = {})
      options = params.pop if params.last.kind_of? Hash
      options ||= {}
      options.reverse_merge! default
      options
    end
   
    def get_field_names
      @field_name ||= self.field_order | self.ungrouped_fields.dup
      @field_name
    end 
    
    # Checks if the field exists, if it does it yields it otherwise it creates a new one.  
    def yield_field(name,&block)
      if self.fields.has_key? name
        field = self.fields[name]
      else
        field = MetaData::Field.new(:name => name,:owner => self)
      end
      
      yield field
    end
  end
end