class Skyline::Site::PagesController < ApplicationController
  before_filter :find_site, :find_page_version_and_url_parts, :possibly_redirect
  
  def show
    renderer = @site.renderer(:controller => self)
    
    if @page_version    
      
      # ========
      # = Page =
      # ========
      if renderer.assigns[:body].blank? && @url_parts.empty?
        renderer.assigns.update(:body => self.response.body)
      end      
      
      render :text => renderer.render(@page_version) if renderer.assigns[:body]
    end    

    # ================================================
    # = Fallback; render 404 if nothing was rendered =
    # ================================================
    self.handle_404 unless performed?
  end
  
  
  protected

  def handle_404
    render :text => "Error 404 :: Page with url \"#{params[:url]}\" doesn't exist.", :status => :not_found    
  end
  
  def find_site
    @site = Skyline::Site.new
  end
  
  def find_page_version_and_url_parts
    url = params[:url].to_s.split("/")
    page, @url_parts = @site.pages.find_by_url(url)
    @page_version = page.andand.published_publication
  end
  
  def possibly_redirect
    return if !@page_version || @url_parts.any?
    if redirect_section = @page_version.sections.detect{|section| section.sectionable.kind_of?(Skyline::Sections::RedirectSection)}
      if redirect_section.sectionable.delay == 0
        redirect_to redirect_section.sectionable.url(request)
      end
    end
  end
end

