class Skyline::VariantsController < Skyline::ApplicationController
  # insert_before_filter_after :authentication, :find_article
  set_callback :authenticate, :after, :find_article

  authorize :create, :by => Proc.new{|user,controller,action| user.allow?(controller.article, :variant_create)  }
  authorize :destroy, :by => Proc.new{|user,controller,action| user.allow?(controller.article, :variant_delete)  }
  authorize :force_edit, :by => "variant_force_edit"
  
  def create
    return handle_unauthorized_user unless Skyline::Configuration.enable_multiple_variants
    
    if params[:variant_id]
      variant_to_clone = @article.variants.find_by_id(params[:variant_id])
      variant = variant_to_clone.clone
      variant.save
    else
      variant = @article.variants.create
    end
    messages[:success] = t(:success, :scope => [:variant, :create, :flashes])
    redirect_to edit_skyline_article_path(@article, :variant_id => variant.id)    
  end
  
  def destroy
    return handle_unauthorized_user unless Skyline::Configuration.enable_multiple_variants
    
    variant = @article.variants.find_by_id(params[:id])
    if variant
      if variant.published_variant?
        messages[:error] = t(:error_variant_published, :scope => [:variant, :destroy, :flashes])
        redirect_to edit_skyline_article_path(@article)
      else        
        variant.destroy 
        if variant.article.frozen?
          messages[:success] = t(:success_variant_and_page, :scope => [:variant, :destroy, :flashes, @article.class])
          redirect_to skyline_articles_path(:type => @article.class.name.underscore)
        else
          messages[:success] = t(:success_variant, :scope => [:variant, :destroy, :flashes])
          redirect_to edit_skyline_article_path(@article)
        end
      end
    else
      notifications[:error] = t(:error, :scope => [:variant, :destroy, :flashes])
      redirect_to edit_skyline_article_path(@article)
    end    
  end
  
  # Updates just the current_editor timestamps
  def force_edit
    if variant = @article.variants.find_by_id(params[:id])
      variant.edit_by!(current_user, :force => true)
      if request.xhr?
        render(:update){|p| p.redirect_to edit_skyline_article_path(@article,:variant_id => variant)}
      else
        redirect_to edit_skyline_article_path(@article,:variant_id => variant)
      end
    end
  end
  
  
  hide_action :article  
  def article
    @article
  end
  
  protected
  
  def find_article
    @article = Skyline::Article.find_by_id(params[:article_id])
    return redirect_to(skyline_articles_path(:type => params[:article_type])) unless @article
    return handle_unauthorized_user unless @article.editable_by?(current_user)
  end
end