class CreateSkylinePageDatas < ActiveRecord::Migration
  
  %w{Page ArticleVersion Article Variant Publication}.each do |c|
    Skyline.send(:remove_const,c.to_sym) if Skyline.send(:const_defined?,c.to_sym)
  end

  class Skyline::Article < ActiveRecord::Base
    set_table_name "skyline_articles"
  end
  
  class Skyline::Page < Skyline::Article
    class Data < ActiveRecord::Base
      has_one :version, :as => :data, :class_name => "Skyline::ArticleVersion"
      set_table_name "skyline_page_data"    
    end
  end
  
  class Skyline::ArticleVersion < ActiveRecord::Base
    set_table_name "skyline_article_versions"
    belongs_to :data, :polymorphic => true
    belongs_to :page, :class_name => "Skyline::Article", :foreign_key => "article_id"
  end
  
  class Skyline::Variant < Skyline::ArticleVersion
  end  

  class Skyline::Publication < Skyline::ArticleVersion
  end  
  
  COLS = %w{url_part title navigation_title custom_title_tag meta_description_tag}
  
  def self.up
 
    create_table :skyline_page_data do |t|
      t.string :url_part
      t.boolean :in_navigation
      t.string :navigation_title
      t.string :title
      t.string :custom_title_tag
      t.text :meta_description_tag
    end
    
    add_column :skyline_article_versions, :data_id, :integer
    add_column :skyline_article_versions, :data_type, :string
         
    Skyline::ArticleVersion.reset_column_information
        
    Skyline::ArticleVersion.all.each do |pv|
      data = Skyline::Page::Data.new(pv.attributes.slice(*COLS))
      data.in_navigation = pv.page.in_navigation
      pv.data = data
      data.save!
      pv.save!      
    end
    
    remove_column :skyline_article_versions, :url_part
    remove_column :skyline_article_versions, :navigation_title
    remove_column :skyline_article_versions, :title
    remove_column :skyline_article_versions, :custom_title_tag
    remove_column :skyline_article_versions, :meta_description_tag
    
    remove_column :skyline_articles, :in_navigation
  end

  def self.down
    add_column :skyline_articles, :in_navigation, :boolean
    
    add_column :skyline_article_versions, :url_part, :string
    add_column :skyline_article_versions, :navigation_title, :string
    add_column :skyline_article_versions, :title, :string
    add_column :skyline_article_versions, :custom_title_tag, :string
    add_column :skyline_article_versions, :meta_description_tag, :text
    
    Skyline::Page::Data.all.each do |pd|
      pd.version.attributes = pd.attributes.slice(*COLS)
      pd.version.page.in_navigation = pd.in_navigation
      pd.version.save!
      pd.version.page.save!
    end    
    
    remove_column :skyline_article_versions, :data_id
    remove_column :skyline_article_versions, :data_type    
    drop_table :skyline_page_data
  end
end
