class Skyline::Content::Stack < Array
  
  def logger
    RAILS_DEFAULT_LOGGER
  end

  def initialize(implementation,types)
    @implementation = implementation
    @raw_types = types
    self.types.each do |type,id|
      instantiate!(type,id)
    end
  end
  
  # You can only push on the stack if the last item on the stack is an object
  # You can't push something on the stack if it's a collection, this would break the types array
  def push(type,id=nil)
    raise NameError, "You can't push onto the stack if the last item is a collection!" if self.types.last.last.nil?
    self.types << [type,id]
    instantiate!(type,id)
  end
  
  # URL based on the current stack
  # <tt>up</tt>::
  #   Integer which tells the url how many type levels we should walk up
  # <tt>down</tt>::
  #   Array of items to add to the types array
  # <tt>collection</tt>::
  #   If set to true doesn't add the ID of the last object on the stack. Doesn't do anything if the last object
  #   on the type array isn't an ID
  #
  # Up and down can be combined! If we currently have [[:pages,1],[:pages,13],[:pages,29]] in the types array
  # and we pass in {:up => 1, :down => [:articles,5]} we will end up with [[:pages,1],[:pages,13],[:articles,5]]
  #
  # If by accident nil is still in the types array (due to incorrectly walkin up the types array) it will be compacted.
  # be aware that this might break things!
  def url_types(options={})
    base = self.types.dup.flatten
    base.pop if options[:collection]
    base = base[0..((-2*options[:up].to_i) -1 )]
    base += options[:down] if options[:down]
    base.compact
  end
  
  # The current last object on the stack
  def current
    self.last
  end
  
  # The parent object on the stack (2 stacklevels up, because one would be the collection)
  def parent
    self[-2]
  end
  
  def has_parent?
    !self.parent.nil?
  end
    
  # The collection of which "current" is a member
  def collection
    self.parent.send(self.parent_collection_name) if self.parent_collection_name
  end
  alias :parent_collection :collection
  
  def collection_name
    self.types.last[0]
  end
  alias :parent_collection_name :collection_name
  
  def klass
    self.current.class
  end
  
  def types
    return @types if @types
    @types = []
    t = @raw_types
    (0..t.size-1).step(2){|i| @types << [t[i].to_sym,t[i+1] && t[i+1].to_i ] }
    @types
  end
  
  def object_for_type(type)
    self[self.types.index(type)]
  end

  protected
  
  def instantiate!(type,id)
    # We're currently operating on an object
    if id
      if self.empty?
        self << @implementation.content_class(type).find(id) 
      else
        self << self.last.send(type).find(id)
      end
    # Now we're working on a collection (we'll instantiate a new object for uniformity)
    else
      if self.empty?
        logger.warn "typ " + type.inspect
        self << @implementation.content_class(type).new      
      else
        logger.debug "Trying: #{type} :: #{self.last.class.reflect_on_association(type.to_sym).inspect}"
        assoc = self.last.class.reflect_on_association(type)
        self << case assoc.macro
          when :has_many : self.last.send(type).build
          else assoc.klass.new
        end
      end
    end
  end
  
end
