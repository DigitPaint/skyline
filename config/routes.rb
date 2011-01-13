ActionController::Routing::Routes.draw do |map|

  # =================
  # = Skyline url's =
  # =================
  map.namespace :skyline do |skyline|
    
    skyline.root :controller => "articles", :action => "index", :type => "skyline/page"
    
    skyline.resources :articles, :collection => {:reorder => :put} do |page|
      page.resources :article_versions
      page.resources :variants, :member => {:force_edit => :put}
      page.resources :publications, :member => {:rollback => :post}
      page.resource :published_publication
    end
    
    # These are currently just used for polling
    skyline.resources :variants do |variant|
      variant.map "current_editor", :controller => "variant_current_editor", :action => "poll"
    end

    skyline.resource :authentication
    skyline.resources :users
    
    skyline.resources :sections
    skyline.resources :content_sections
    skyline.resources :content_items
    skyline.resources :link_section_links
    skyline.resources :redirects, :only => [:new]
    
    skyline.resources :locales, :only => [:show]

    skyline.namespace :media do |media|
      media.resources :dirs do |dirs|
      	# Alert! Routes hard coded in app/views/skyline/media_files/_index.html.erb        
        dirs.resources :files
        
        dirs.connect 'data/:size/:name.:format',
            :controller => 'data',
            :action => 'show',
            :conditions => { :method => :get }
        dirs.connect 'data/:name.:format',
            :controller => 'data',
            :action => 'show',
            :conditions => { :method => :get }        
      end
    end    
    
    skyline.namespace :browser do |browser|
      browser.resources :images
      browser.resources :links
      browser.resources :pages
      browser.resources :files
      browser.namespace :tabs do |tabs|
        tabs.namespace :media_library do |media_library|
          media_library.resources :media_dirs do |media_dir|
            media_dir.resources :media_files
          end
        end
      end          
    end
    
    skyline.namespace :content do |content|
      content.namespace :editors do |editors|
        editors.connect 'editable_list/:action/:id', :controller => "editable_list"
        editors.connect 'joinable_list/:action/:id', :controller => "joinable_list"
      end
    end
    skyline.connect 'content/:action/*types', :controller => "content"
    
    skyline.resources :settings, :except => [:create, :destroy]
    
  end

  # ========================
  # = Implementation url's =
  # ========================
  #Media files data route
  
  map.connect 'media/dirs/:media_dir_id/data/:size/:name.:format',
      :controller => 'skyline/site/media_files_data',
      :action => 'show',
      :conditions => { :method => :get }
  map.connect 'media/dirs/:media_dir_id/data/:name.:format',
      :controller => 'skyline/site/media_files_data',
      :action => 'show',
      :conditions => { :method => :get }
            
  # Default pages renderer.
  # map.connect '*url', :controller => "skyline/site/pages", :action => "show"
end
