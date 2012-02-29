# @private
class Skyline::ObjectRef < Skyline::RefObject	
  after_destroy :destroy_referable
  
	def respond_to?(m, include_private = false)
		return true if super
		if self.referable
			self.referable.respond_to?(m)
		else
			super
		end
	end
	
	def method_missing(m,*a)
		if self.referable && self.referable.respond_to?(m)
			self.referable.send(m,*a)
		else
			super
		end
	end			
	
	def blank?
	  self.referable.blank?
  end
  
  def present?
	  self.referable.present?
  end
  
  def external?
    self.referable.andand.respond_to?(:external?) ? self.referable.external? : false
  end
  
  def file?
    self.referable_type == "Skyline::MediaFile"
  end
  
  def dup
    super.tap do |dup|
      dup.referable = self.referable.dup if self.referable.kind_of?(Skyline::ReferableUri)
    end
  end
  
  protected
  def destroy_referable
    self.referable.destroy if self.referable.kind_of?(Skyline::ReferableUri)
  end
end