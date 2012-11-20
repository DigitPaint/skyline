class Skyline::CustomArticle < Skyline::Article  
  class Data < Skyline::Article::Data
    self.table_name = :skyline_test_article_data
    
  end
  
  def self.right_prefix
    "custom_article"      
  end
  
end
