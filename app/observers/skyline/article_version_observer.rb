class Skyline::ArticleVersionObserver < ActiveRecord::Observer
  attr_accessor :controller
  def before(controller)
    self.controller = controller
  end
  def after(controller)
    self.controller = nil
  end  

  def before_create(article_version)
    article_version.creator = self.controller.send(:current_user) if self.controller
  end
          
  def before_save(article_version)
    article_version.last_updated_by = self.controller.send(:current_user) if self.controller
  end
end