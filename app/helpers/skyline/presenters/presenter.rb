# Use options[:collection] = collection_name to specify this list is sub-colleciton of
# a parent object.

class Skyline::Presenters::Presenter
  class << self
    def create(presenter,records,fieldset,template,options={})
      klass = case presenter
        when :article : Skyline::Presenters::ArticleList
        else Skyline::Presenters::Table
      end      
      klass.new(records,fieldset,template,options)
    end
  end
  
  attr_accessor :collection,:options, :fieldset
  def initialize(collection, fieldset,template, options={})
    @collection = collection
    @fieldset = fieldset
    @template = template
    options.reverse_merge!(:navigation => true)
    @options = options
    # Make sure we initialize the stack
    self.stack
  end
  
  # Delegate all missing methods (helpers) to the template
  def method_missing(method,*params)
    @template.send(method,*params)
  end
  # Speedup 
  def content_tag(*params); @template.content_tag(*params); end # :nodoc:
  
  def output
    [header,body,footer].join("\n")
  end
  
  def header; ""; end
  def body; ""; end
  def footer; ""; end
  
  protected
  
  def edit_button(record)
		link_to button_text(:edit),{:action => "edit", :types => stack.url_types(:down => [record.id]), :return_to  => url_for({:filter => params[:filter]})}, :class => "button small"
  end
  
  def delete_button(record)
    link_to_remote button_text(:delete),{ 
                   :url => {:action => "delete",:types => stack.url_types(:down => [record.id]),:return_to  => url_for({})},
                   :confirm => t(:confirm_deletion, :scope => [:content,:list], :class => self.fieldset.singular_name) }, :class => "button small red"
  end

    
  # We have to create our own stack, since it may be possible that we're
  # inline of some other screen. We have to add the collection we're listing to this stack
  # this may mean we don't have to do anything at all because the main stack is aleady the right one
  # Navigation within inlin lists is prohibited, because we do not support sub-list navigation on an inline list yet.
  def stack
    return @stack if @stack
    @stack = @template.stack.dup
    
    if self.options[:collection] && !(@stack.collection_name == self.options[:collection])      
      @stack.push(self.options[:collection])
      self.options[:navigation] = false
    end
    @stack
  end  

  def heading_collection(fieldset=self.fieldset,cache=true)
    return @heading_collection if @heading_collection && cache
    
    @heading_collection = []

    fieldset.each_field do |field|
      next if field.hidden_in :list
      case field
        when Skyline::Content::MetaData::Field       
          @heading_collection << field
        when Skyline::Content::MetaData::FieldGroup
          @heading_collection += heading_collection(field,false)
      end 
    end

    # Publishable
    @heading_collection << Skyline::Content::MetaData::Field.new(:name => :published, :owner => fieldset, :editor => :publish) if fieldset.kind_of?(Class) && fieldset.publishable?  

    @heading_collection        
  end

  def value(record,field)
    if field.association?
      case field.reflection.macro
        when :has_many 
			    link_to "#{record.send(field.reflection.name).count.to_s} items (view)", :action => "list", :types => stack.url_types(:down => [record.id,field.name])
			  when :belongs_to
          sub_record = record.send(field.reflection.name)
			    sub_record && sub_record.human_id || ""
		  end
    else
      begin
      content = field.value(record)
      end
      
      case field.editor
        # :publish editor is temporary editor created by the presenter itself.
        when :publish : [content ? image_tag("/skyline/images/icons/true.gif", :alt => t(:true, :scope => [:icons])) : image_tag("/skyline/images/icons/false.gif", :alt => t(:true, :scope => [:icons])),{:class => "center"}]
        else normalize_content(content,field)          
      end
    end        
  end
  
  def normalize_content(content,field=nil)
    case content 
      when /<.+?>/ : 
        if field.filter_html == false
          content.to_s
        else
          truncate(simple_format(strip_tags(content.gsub("<br />", "<br />\n").gsub("</p>", "</p>\n"))),150)
        end
      when String : truncate(content,150)
      when TrueClass,FalseClass : [(content ? image_tag("/skyline/images/icons/true.gif") : image_tag("/skyline/images/icons/false.gif")),{:class => "center"}]
      when Date,Time : l(content, :format => :long)
      else content.to_s
    end 
  end
  
end