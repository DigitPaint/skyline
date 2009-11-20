class Skyline::PublicationsController < Skyline::ApplicationController
  
  before_filter :find_article
  before_filter :find_publication, :only => [:rollback]
  
  authorize :rollback, :by => "article_variant_create"
  
  def index
    if request.xhr?
      render :update do |p|
        p << "var s = function(){"
        p << "var sd = new Skyline.Dialog({width: 700, height: 500});"
        p << "sd.setTitle('#{escape_javascript(t(:dialog_title, :scope => [:publication,:index]))}');"
        p << "sd.setContent('" + escape_javascript(render(:partial => "index")) + "');"
        p << "sd.setup(); sd.show();"
        p << "sd.layout = new Application.Layouts.History(sd.contentEl.getElement('form'));"
        p << "sd.layout.rollbackUrl = '"+escape_javascript(rollback_skyline_article_publication_path(@article, "000"))+"'"
        p << "}()"
      end
    end
  end
  
  def rollback
  	return handle_unauthorized_user if @article.locked? && !current_user.allow?(:page_lock)
  	
  	new_variant = @publication.rollback({'name' => @publication.name})
  	notifications[:success] = t(:success, :scope => [:publication, :rollback, :flashes])
  	redirect_to edit_skyline_article_path(@article, :variant_id => new_variant.id)
	rescue
		messages[:error] = t(:error, :scope => [:publication, :rollback, :flashes])
		redirect_to edit_skyline_article_path(@article)
	end
  
  protected
  
  def find_article
    @article = Skyline::Article.find_by_id(params[:article_id])
    return redirect_to(skyline_articles_path(:type => params[:article_type])) unless @article
  end    
  
  def find_publication
    @publication = @article.publications.find_by_id(params[:id])
    return redirect_to(edit_skyline_articles_path(@article)) unless @publication
	end
end