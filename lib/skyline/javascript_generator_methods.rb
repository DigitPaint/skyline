# @private
module Skyline::JavascriptGeneratorMethods
  def message(type,message,options={})
    record Skyline::MessageGenerator.new(type,message,options={})
  end
  
  def notification(type,message,options={})
    record Skyline::MessageGenerator.new(type,message,options={})    
  end  
end