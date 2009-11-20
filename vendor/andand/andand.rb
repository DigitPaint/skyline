# Taken from http://andand.rubyforge.org/

module AndAnd

  # This module is included in Object, so each of these methods are added
  # to Object when you require 'andand'. Each method is an *adverb*: they are
  # intended to be enchained with another method, such as receiver.adverb.method
  #
  # The purpose of an adverb is to modify what the primary method returns.
  #
  # Adverbs also take blocks or procs, passing the receiver as an argument to the
  # block or proc. They retain the same semantics with a block or proc as they
  # do with a method. This behaviour weakly resembles a monad.
  module ObjectGoodies

    # Returns nil if its receiver is nil, regardless of whether nil actually handles the
    # actual method ot what it might return.
    #
    #    'foo'.andand.size => 3
    #    nil.andand.size => nil
    #    'foo'.andand { |s| s << 'bar' } => 'foobar'
    #    nil.andand { |s| s << 'bar' } => nil
    def andand (p = nil)
      if self
        if block_given?
          yield(self)
        elsif p
          p.to_proc.call(self)
        else
          self
        end
      else
        if block_given? or p
          self
        else
          MockReturningMe.new(self)
        end
      end
    end
  end
  
end

class Object
  include AndAnd::ObjectGoodies
end

unless Module.constants.include?('BlankSlate')
  if Module.constants.include?('BasicObject')
    module AndAnd
      class BlankSlate < BasicObject
      end
    end
  else
    module AndAnd
      class BlankSlate
        def self.wipe
          instance_methods.reject { |m| m =~ /^__/ }.each { |m| undef_method m }
        end
        def initialize
          BlankSlate.wipe
        end
      end
    end
  end
end

module AndAnd

  # A proxy that returns its target without invoking the method you
  # invoke. Useful for nil.andand and #dont
  class MockReturningMe < BlankSlate
    def initialize(me)
      super()
      @me = me
    end
    def method_missing(*args)
      @me
    end
  end

  # A proxy that returns its target after invoking the method you
  # invoke. Useful for #me
  class ProxyReturningMe < BlankSlate
    def initialize(me)
      super()
      @me = me
    end
    def method_missing(sym, *args, &block)
      @me.__send__(sym, *args, &block)
      @me
    end
  end

end

