class Skyline::TestArticle < Skyline::Article  
  class Data < Skyline::Article::Data
    self.table_name = :skyline_test_article_data
    
    # include Skyline::HasManyReferablesIn
    # has_many_referables_in :intro
    # 
    # include Skyline::BelongsToReferable
    # belongs_to_referable :link        
  end      
end
