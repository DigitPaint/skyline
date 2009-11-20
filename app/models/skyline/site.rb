class Skyline::Site
  class << self
    def find_by_id(id)
      self.new
    end
  end
  
  def root
    Skyline::Page.find_by_parent_id(nil)
  end
  
  def pages
    Skyline::Page
  end
  
  def renderer(options = {})
    Skyline::Renderer.new(options)
  end
  
  def named_scope_with_site_for(article_data_class)
    {}
  end
end
