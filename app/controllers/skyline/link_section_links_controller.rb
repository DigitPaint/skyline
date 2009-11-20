class Skyline::LinkSectionLinksController < Skyline::ApplicationController
  def new
    return unless request.xhr?
    render :update do |page|
      link = Skyline::LinkSectionLink.new
      link_guid = Guid.new
      
      fields_for params[:object_name], link do |sectionable_form|
        page.insert_html(:bottom, "section-#{params[:guid]}-links", :partial => "form", :locals => {:sectionable_form => sectionable_form, :link => link, :guid => params[:guid], :link_guid => link_guid})
        page << "linkSectionLinksSortable#{params[:guid].to_s.gsub("-","")}.addItem('link_section_#{link_guid}');"
      end
    end
  end
end