class Skyline::ArticlesController < Skyline::ApplicationController
  
  insert_before_filter_after :authentication, :find_article, :only => [:edit, :update, :destroy]
  
  authorize :index, :by => Proc.new{|user,controller,action| user.allow?(controller.article || controller.class_from_type, :index)  }
  authorize :create, :by => Proc.new{|user,controller,action| user.allow?(controller.article || controller.class_from_type, :create)  }  
  authorize :edit, :by => Proc.new{|user,controller,action| user.allow?(controller.article || controller.class_from_type, :show)  }  
  authorize :update, :reorder, :by => Proc.new{|user,controller,action| user.allow?(controller.article || controller.class_from_type, :update)  }  
  authorize :destroy, :by => Proc.new{|user,controller,action| user.allow?(controller.article || controller.class_from_type, :variant_delete)  }  
    
  layout :determine_layout
  
  self.default_menu_item = :content_library

  def index
    case params[:type] 
    when "skyline/page" 
      return redirect_to(edit_skyline_article_path(Skyline::Page.root))
    when "skyline/page_fragment"
      return redirect_to(edit_skyline_article_path(Skyline::PageFragment.first)) if Skyline::PageFragment.first.present?
    end
    @articles = class_from_type(params[:type]).all
  end
  
  def create
    if params[:type] == "skyline/page"
      relative_to_page = Skyline::Page.find_by_id(params[:article_id])
      return redirect_to(edit_skyline_article_path(Skyline::Page.root)) unless relative_to_page
      article = relative_to_page.create_new!(params[:position].to_sym)
    else
      article = class_from_type(params[:type]).new(params[:article])
      article.save
    end
    
    if article.errors.any?
      messages[:error] = t(:error, :errors => Array(article.errors.full_messages).to_sentence, :scope => [article.class, :create, :flashes])
      if params[:type] == "skyline/page"
        @target = edit_skyline_article_path(relative_to_page)
      else
        @target = skyline_articles_path(:type => params[:type])
      end
    else
      @target = edit_skyline_article_path(article)
      flash[:select_page_title] = true
    end
    
    if request.xhr?
      render :update do |p|
  		  p.redirect_to @target
      end
    else
		  redirect_to @target
  	end
  end

  def edit  
    case @article
      when Skyline::Page,Skyline::PageFragment then self.current_menu_item = :pages
    end
    
    if @variant.editable_by?(current_user)
      @variant.edit_by!(current_user) 
    else
      messages.now[:error] = render_to_string(:partial => "currently_editing")      
      return render(:action => "edit_preview_only")
    end
    
    if flash[:show_errors_for_publication]
      @variant.data.to_be_published = true
      @variant.valid?
    end
    
  end
  
  def update
    return handle_unauthorized_user unless @article.editable_by?(current_user)
    
    case @article
      when Skyline::Page,Skyline::PageFragment then self.current_menu_item = :pages
    end
        
    # @page.attributes= with all variant_attributes will load all variants which in turn
    #   will cause all versions of the variants to be increased by 1
    # Solution is to save the one and only variant seperately
    article_params = params[:article].dup if params[:article]
    if variant_attributes = article_params.andand[:variants_attributes].andand["1"]
      article_params.delete(:variants_attributes)
      variant_id = variant_attributes.delete(:id)
      @variant = @article.variants.find(variant_id)
    elsif params[:variant_id]
      @variant = @article.variants.find(params[:variant_id])
    end    

    if params["clone_variant"] == "1"
      name = variant_attributes.andand[:name]
      name = @variant.name + "_copy" if name.blank?
      new_variant = @article.variants.create(:name => name, :current_editor_id => current_user.id)
    end

    
    saved = false
    begin
      Skyline::Article.transaction do
        if params["clone_variant"] == "1"
          @variant = @variant.clone()
          
          # Dirty hack so AR thinks this object isn't new.
          @variant.attributes = new_variant.attributes.except("version")
          @variant.id = new_variant.id          
          class << @variant; def new_record?; false; end; end
          @variant.save!
        else
          @article.attributes = article_params          
          @article.save!
          
          if variant_attributes
            @variant.attributes = variant_attributes 
            @variant.save!
          end          
        end
        saved = true
      end
    rescue ActiveRecord::RecordInvalid
      logger.debug "Article update failed: #{@article.errors.inspect}"
      logger.debug "Variant update failed: #{@variant.errors.inspect}"
    end
    
    if params[:article].has_key?(:move_behind)
      # no notifications needed
      render :update do |p|
      end
    elsif request.xhr?
      render :update do |p|
        if saved
          if @article.locked?
            p.notification :success, t(:locked, :scope => [@article.class, :update, :flashes])
            p << "$$('#article_#{@article.id} span')[0].addClass('locked')" if @article.kind_of?(Skyline::Page)
          else
            p.notification :success, t(:unlocked, :scope => [@article.class, :update, :flashes])
            p << "$$('#article_#{@article.id} span')[0].removeClass('locked')" if @article.kind_of?(Skyline::Page)
          end
        else
          if @article.locked?
            p.message :error, t(:lock_failed, :scope => [@article.class, :update, :flashes])
          else
            p.message :error, t(:unlock_failed, :scope => [@article.class, :update, :flashes])
          end
        end
        p.replace "article_security", :partial => "security"
      end
    else
      if saved
        notifications[:success] = t(:success, :scope => [@article.class, :update, :flashes])
        redirect_to edit_skyline_article_path(@article, :variant_id => @variant.id)
      else
        if @variant.errors.on(:version)
          messages.now[:error] = @variant.errors.on(:version)
        else
          messages.now[:error] = t(:error, :scope => [@article.class, :update, :flashes])
        end
        render :action => :edit
      end          
    end
    
    logger.debug("------ article validation: #{@article.errors.full_messages.inspect}")
  end  
  
  def destroy
    return handle_unauthorized_user unless @article.editable_by?(current_user)

    if @article.destroyable?
      if @article.destroy
        notifications[:success] = t(:success, :scope => [@article.class, :destroy, :flashes])
        if @article.respond_to?(:parent) && @article.parent.present?
          redirect_to edit_skyline_article_path(@article.parent)
        else
          redirect_to skyline_articles_path(:type => @article.class)
        end
      else
        notifications[:error] = t(:error, :scope => [@article.class, :destroy, :flashes])
        redirect_to edit_skyline_article_path(@article)
      end
    else
      if @article.published?
        notifications[:error] = t(:error_page_published, :scope => [@article.class, :destroy, :flashes])
        redirect_to edit_skyline_article_path(@article)
      elsif @article.persistent?
        notifications[:error] = t(:error_page_persistent, :scope => [@article.class, :destroy, :flashes])
        redirect_to edit_skyline_article_path(@article)
      elsif @article.children.any?
        notifications[:error] = t(:error_page_has_children, :scope => [@article.class, :destroy, :flashes])
        redirect_to edit_skyline_article_path(@article)
      else
        notifications[:error] = t(:error, :scope => [@article.class, :destroy, :flashes])
        redirect_to edit_skyline_article_path(@article)
      end
    end
  end
  
	# expects:
	#   params[:pages]  - Array of Page IDs in the new order
  def reorder
  	return unless request.xhr?
  	Skyline::Page.reorder(params[:pages])
  	# TODO: render....
	end  

  # =============================
  # = Non action public methods =
  # =============================
  hide_action :article, :class_from_type
  
  def article
    @article
  end
    
  def class_from_type(type=params[:type])
    raise "Cannot infer class from #{type.inspect}" if type.blank?
    @klass = type.camelcase.constantize
    if @klass.ancestors.include?(Skyline::Article)
      return @klass 
    else
      raise "Class #{klass.to_s} is not a subclass of Skyline::Article"
    end
  end

  protected
  
  def find_article
    @article = Skyline::Article.find_by_id(params[:id])
    @variant = @article.variants.find_by_id(params[:variant_id]) if params[:variant_id]
    @variant ||= @article.default_variant
    @variant ||= @article.variants.first
    @renderable_scope = @article.renderable_scope
  end
  
  def determine_layout
    if @article && (@article.kind_of?(Skyline::Page) || @article.kind_of?(Skyline::PageFragment)) || params[:type] == "skyline/page" || params[:type] == "skyline/page_fragment"
      "skyline/layouts/pages"
    else
      "skyline/layouts/articles"
    end
  end

end