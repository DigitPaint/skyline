class Skyline::VersionStamper < ActiveRecord::Observer
  attr_accessor :controller
  def before(controller)
    self.controller = controller
  end
  def after(controller)
    self.controller = nil
  end  
  
  def after_save(record)
    user,versioner = self.current_user,self.versioner
    return if !user && !versioner
    
    versioner.increase!(record,current_user)
  end

  def after_destroy(record)
    user,versioner = self.current_user,self.versioner
    return if !user && !versioner
  
    versioner.destroy!(record)
  end

  protected

  def current_user
    self.controller.send :current_user
  end
  
  def current_implementation
    self.controller.send :current_implementation
  end

  def versioner
    Skyline::Content::Versioning::Version
  end
  
  def logger
    RAILS_DEFAULT_LOGGER
  end
  
end