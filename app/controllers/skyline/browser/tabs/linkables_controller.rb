class Skyline::Browser::Tabs::LinkablesController < Skyline::ApplicationController
  
  def show
    @linkable_type = Skyline::Linkable.linkables.find{|l| l.name == params[:id]}
    @linkables = @linkable_type.all
    @linkable = @linkable_type.find_by_id(params[:referable_id])
    
    render :update do |p|
      p << "document.id(\"browserLinkableLinkables\").getElements(\"li a\").removeClass(\"active\");"
      p << "document.id(\"browserLinkableLinkables#{@linkable_type.name}\").getElement(\"a\").addClass(\"active\");"      
    	p.replace_html("browserLinkableContentPanel", :partial => "show")
    end
  end
  
end