require 'enumerator'

class Skyline::ContentController < Skyline::Skyline2Controller
  
  layout "skyline/layouts/content"
    
  self.default_menu_item = :content_library   
    
  def index
    if request.xhr?
      render :update do |p|
        p.replace_html "leftContentContentPanel", :partial => "types"
      end
    else
      if first_element = (Skyline::Configuration.articles + Skyline::Configuration.content_classes).first
		    if first_element.ancestors.include?(Skyline::Article)
		      redirect_to skyline_articles_path(:type => first_element)
		    else
		      redirect_to object_url(first_element, :controller => "skyline/content", :action => "list") 
	      end
	    end
    end
  end
    
  def list
    list_elements!
  end
  
  def show
    @element = stack.last
    render :layout => "popup"
  end
  
  def edit
    @element = stack.last
    
    # Just redirect away from here like we would have done after a save.
    return redirect_after(:save, @element) if params[:discard]
    
    if request.post?        
      begin
        @element.attributes = params[:element]
        @element.from_version = params[:version].to_i
      rescue ActiveRecord::RecordInvalid
        @element.keep_version!
        messages.now[:error] = l(:content,:flashes,:invalid_record)
        return
      end

      if !@element.matching_versions?
        # Failed version
        show_url = object_url(@element,{:action => "show"})
        messages.now[:notice] = l(:version_conflict, 
                                :scope => [:content, :flashes],
                                :current_version => @element.current_version, 
                                :your_version => params[:version], 
                                :current_author => @element.current_author,
                                :show_link => "<a href='#{show_url}' onclick=\"popup('#{show_url}',800,800,'scrollbars=yes'); return false\">#{t(:see_changes_by, :scope => [:content, :edit], :current_author => @element.current_author)}</a>")
      else
        if @element.save
          notifications[:success] = t(:successfully_saved, :scope => [:content, :flashes], :class => @element.class.singular_name)
          redirect_after :save, @element
        else
          @element.keep_version!
          messages.now[:error] = t(:validation_error, :scope => [:content, :flashes], :class => @element.class.singular_name)
        end        
      end
    end    
  end
  
  def delete
    @element = stack.last
    if request.post?
      if @element.destroy
        notifications[:success] = t(:successfully_deleted, :scope => [:content, :flashes], :class => @element.class.singular_name)
      else
        messages[:error] = t(:fail_deleted, :scope => [:content, :flashes], :class => @element.class.singular_name)
      end
    end
    respond_to do |format|
      format.html{ redirect_after(:delete) }
      format.js do
        render(:update){|p| p.redirect_to controller.send(:redirect_url_after,:delete) }
      end
    end
  end
  
  def order
    if request.xhr? && stack.klass.orderable? && params[:order]
      ids = params[:order].split(",").collect{|s| s.to_i}
      if ids.size > 1 && stack.klass.reorder(ids)
        render(:update){|p| p.call "Application.addOddEven", "#{stack.klass.name}Listing", "tbody tr"}
      elsif ids.size <= 1
        render :nothing => true        
      else
        list_elements!
        render :update do |p|
          p.replace_html "contentEditPanel", presenter_for(@elements,stack.klass)
          p << "$('contentEditPanel').retrieve('skyline.layout').setup()";
        end
      end
    end  
    redirect_to :action => "list", :types => stack.url_types(:up => 1, :collection => true) if !request.xhr?
  end
  
  def create
    @element = stack.last    
    @element.attributes = params[:element]
            
    if request.post?
      @element.relate_to(stack.parent) if stack.has_parent?
      if @element.save
        notifications[:success] = t(:successfully_saved, :scope => [:content,:flashes], :class => @element.class.singular_name)
        redirect_after :save, @element
      else
        messages.now[:error] = t(:validation_error, :scope => [:content, :flashes], :class => @element.class.singular_name)
      end
    end
  end
  
  def export
    if stack.size > 1
      exportfile = stack.parent_collection.send("export")
    else
      exportfile = stack.klass.send("export")
    end
    content_type = "application/octet-stream"
    filename = "export_#{Time.now.strftime('%Y-%m-%d')}.xml"
    send_data exportfile.to_s, :type => content_type, :filename => filename
  end
    
  def import
    if request.xhr?
      if stack.size > 1
        klass = stack.parent_collection.to_s
      else
        klass = stack.klass.to_s
      end
      
      url = object_url(stack.current, {:action => "import"})
          
      render :update do |p|
        p << dialog(t(:dialog_title, :scope => [:content, :import]), :partial => "import", :locals => {:url => url, :klass => klass},  :width => 400)
      end
    end  
    
    if request.post?
      if params[:xml_file].present?
        xml = params[:xml_file].read
        errors = stack.klass.import(xml)
        if errors === true || errors.empty?
          notifications[:success] = t(:successfully_imported, :scope => [:content, :flashes])
        else
          notifications[:error] = t(:import_failed, :scope => [:content, :flashes], :errors => "<br /><br />\n <ul><li>#{errors.join("</li>\n<li>")}</li></ul>")
        end          
      else
        notifications[:error] = t(:no_import_file_selected, :scope => [:content, :flashes])
      end
      redirect_to params[:return_to]
    end  
  end
  
  # Editor can only be called on editors and when params[:field] is set
  verify :xhr => true, :only => [:field]
  def field
    @element = stack.last
    @element.attributes = params[:element]
    render :update do |p|
      p.replace input_id("field","element",params[:field]), content_field(@element.class, 'element', @element.class.fields[params[:field].to_sym] || Field.new(:name => params[:field]), @element)
    end
  end
  
  def error
  end  
  
  protected
  
  def redirect_after(method,object=nil)
    redirect_to redirect_url_after(method,object)
  end
  
  def redirect_url_after(method,object=nil)
    if method == :save && params[:return_to] == "self"
      types = stack.url_types
      types << object.id if object && !stack.url_types.last.kind_of?(Fixnum)
      {:action => "edit", :types => types}
    else
      params[:return_to] || {:action => "list", :types => stack.url_types(:up => 1, :collection => true)}
    end    
  end
  
  # Create the @elements array according to stack
  def list_elements!
    if stack.size > 1
      @elements = stack.parent && stack.parent_collection.find_for_cms(:all, :filter => params[:filter])
    else
      @count = stack.last.class.count_for_cms(:all,:self_referential => false, :filter => params[:filter])
      @elements = stack.last.class.paginate_for_cms :all, :page => params[:page], :per_page => 30, :self_referential => false, :filter => params[:filter]
    end    
  end  

end
