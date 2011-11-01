class Skyline::PublishedPublicationsController < Skyline::ApplicationController
  before_filter :find_article

  def create
    variant = @article.variants.find_by_id(params[:variant_id])
    if !variant || !variant.editable_by?(current_user)
      return redirect_to(skyline_page_path(@article)) 
    end
    
    if variant.publish
      messages[:success] = t(:success, :scope => [:published_publication, @article.class, :create, :flashes])
    else
      notifications[:error] = t(:error, :scope => [:published_publication, @article.class, :create, :flashes])
      flash[:show_errors_for_publication] = true
    end    
    redirect_to edit_skyline_article_path(@article, :variant_id => variant.id)
  end
  
  def destroy
    if @article.depublishable?
      @article.depublish
      messages[:success] = t(:success, :scope => [:published_publication, @article.class, :destroy, :flashes])
    else
      if @article.persistent?
        notifications[:error] = t(:error_persistent, :scope => [:published_publication, @article.class, :destroy, :flashes])
      else
        notifications[:error] = t(:error, :scope => [:published_publication, @article.class, :destroy, :flashes])
      end
    end
    
    redirect_to edit_skyline_article_path(@article, :variant_id => params[:variant_id])
  end
  
  protected
  def find_article
    @article = Skyline::Article.find_by_id(params[:article_id])
    return redirect_to(skyline_articles_path(:type => params[:article_type])) unless @article
    return handle_unauthorized_user unless @article.editable_by?(current_user)
  end
end