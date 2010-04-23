# The JavascriptGeneratorMethods are added so they can be used within RJS blocks
# and `render :update` blocks.
# 
# @private
module Skyline::JavascriptGeneratorMethods
  def message(type,message,options={})
    record Skyline::MessageGenerator.new(type,message,options={})
  end
  
  def notification(type,message,options={})
    record Skyline::NotificationGenerator.new(type,message,options={})    
  end  
end