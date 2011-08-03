class Skyline::PageFragment < Skyline::Article
  class Data < Skyline::Article::Data
    after_initialize :set_defaults
    
    protected
    
    def set_defaults
      self.title ||= I18n.t(:default_title, :scope => [:page_fragment])    
    end    
  end  
  def self.right_prefix
    "page_fragment"
  end
  
  named_scope :ordered_by_title, :include => :default_variant_data, :order => "#{Data.table_name}.title"
end