# class NewsletterEditor < Configure
#   
# end
#
# NewsletterEditor.configure do |c|
#   c.upload_path = "bla"
#   c.fli = "fla"
# end
#
require 'singleton'
class Configure
  include Singleton

  class ConfigurationStorage < Hash
    def method_missing(meth,*params)
      meth = meth.to_s
      if meth =~ /=$/
        self[meth.sub(/=$/,"")] = params.first
      elsif self.has_key?(meth)
        self[meth]
      else 
        super(meth,*params)
      end
    end  
  end  
  
  class << self
    def configure(*params,&block)
      self.instance.configure(*params,&block)
    end
    
    def defaults(*params, &block)
      if block_given?
        yield self.instance.instance_variable_get(:@_defaults)
      else
        self.instance.instance_variable_get(:@_defaults)
      end
    end
    
    def configuration
      self.instance.configuration
    end
    
    def method_missing(meth,*params)
      if self.instance.has_key?(meth.to_s)
        self.instance.send(meth, *params)
      else
        super(meth,*params)
      end
    end
  end
    
  def initialize
    @_configuration = {}
    @_defaults = ConfigurationStorage.new
  end
  
  def configure(*params)
    if block_given?
      self.before_configure      
      yield self
      self.after_configure
    else
      self
    end
  end
  
  
  # Called before a configureblock is given
  def before_configure
  end
  
  # Called after the configure block
  def after_configure
  end
  
  def method_missing(meth,*params)
    meth = meth.to_s
    if meth =~ /=$/
      self[meth.sub(/=$/,"")] = params.first
    elsif has_key?(meth)
      self[meth]
    else 
      super(meth,*params)
    end
  end
  
  def [](key)
    if @_configuration.has_key?(key) 
      @_configuration[key] 
    elsif @_defaults.has_key?(key)
      @_defaults[key]
    end
  end
  
  def []=(key,value)    
    @_configuration[key] = value
  end
  
  def has_key?(key)
    @_configuration.has_key?(key) || @_defaults.has_key?(key)
  end
  
  def configuration
    @_defaults.merge(@_configuration)
  end
  
end

# Some basic tests (Don't laugh!)
if __FILE__ == $0
  class T1 < Configure
    defaults do |c|
      c.name = "Test1"
    end
    defaults.id = 1
  end
  
  class T2 < Configure
    defaults do |c|
      c.name = "Test2"
      c.test = true
      c.thingy = nil
    end
    defaults.id = 2
    
    def thingy=(value)
      puts "HELP!" if value.nil?
      self[:thingy] = value
    end
  end
  
  T2.configure.name = "Test - 2"
  T2.configure do |conf|
    conf.bla = "blaa"
    conf.thingy = nil
  end
  
  puts T1.configuration.inspect
  puts T2.configuration.inspect
  
  puts T1.name  
  
end