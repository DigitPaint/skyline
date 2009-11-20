class AddArticleDataPointers < ActiveRecord::Migration

  %w{ArticleVersion Publication Variant Article Page}.each do |c|
    Skyline.send(:remove_const,c.to_sym) if Skyline.send(:const_defined?,c.to_sym)
  end

  class Skyline::ArticleVersion < ActiveRecord::Base
    set_table_name "skyline_article_versions"     
  end

  class Skyline::Publication < Skyline::ArticleVersion
  end

  class Skyline::Variant < Skyline::ArticleVersion
  end  

  class Skyline::Article < ActiveRecord::Base
    set_table_name "skyline_articles" 

    belongs_to :published_publication, :class_name => "Skyline::Publication"
    has_many :variants, :class_name => "Skyline::Variant"
  end

  class Skyline::Page < Skyline::Article
  end
    
  def self.up
   add_column :skyline_articles, :published_publication_data_id, :integer
   add_column :skyline_articles, :default_variant_id, :integer
   add_column :skyline_articles, :default_variant_data_id, :integer    
    
    Skyline::Article.reset_column_information    
    
    Skyline::Page.all(:include => :published_publication).each do |a|
      a.published_publication_data_id = a.published_publication.data_id if a.published_publication
      df = a.variants.scoped(:order => "updated_at DESC").first
      a.default_variant_id = df.id
      a.default_variant_data_id = df.data_id
      a.save!
    end
  end

  def self.down
    remove_column :skyline_articles, :default_variant_data_id
    remove_column :skyline_articles, :default_variant_id
    remove_column :skyline_articles, :published_publication_data_id
  end
end
