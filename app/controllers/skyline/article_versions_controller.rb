class Skyline::ArticleVersionsController < Skyline::ApplicationController
  before_filter :find_article, :load_renderable_scope, :find_article_version, :possibly_redirect

  def show
    renderer = @renderable_scope.renderer(:controller => self)
    body = renderer.render(@article_version)
    
    if wrapper_publication = @article.preview_wrapper_page.andand.published_publication
      render :text => renderer.render(wrapper_publication, :assigns => {:body => body})
    else
      render :text => body
    end
  end
  
  protected
  
  def find_article
    @article = Skyline::Article.find_by_id(params[:article_id])
    return redirect_to(skyline_articles_path(:type => params[:type])) if @article.blank?
  end  

  def load_renderable_scope
    @renderable_scope = Skyline::WildcardRenderableScope.new
  end

  def find_article_version
    @article_version = @article.versions.find_by_id(params[:id])
    render(:text => "404 :: PageVersion [#{params[:id]}] doesn't exist.", :status => :not_found) unless @article_version
  end  
  
  def possibly_redirect
    if redirect_section = @article_version.sections.detect{|section| section.sectionable.kind_of?(Skyline::Sections::RedirectSection)}
      if redirect_section.sectionable.delay == 0
        redirect_to new_skyline_redirect_url(:redirect_section_id => redirect_section.id)
      end
    end
  end  
  
end