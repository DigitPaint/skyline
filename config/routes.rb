Skyline::Engine.routes.draw do
  namespace :skyline, :path => "" do
    root Skyline::Configuration.default_route
    
    resources :articles do
      collection do
        put :reorder
      end
      resources :article_versions
      resources :variants do
        member do
          put :force_edit
        end
      end
      resources :publications do
        member do
          post :rollback
        end
      end
      resource :published_publication
    end
    
    resources :variants do
      match "current_editor" => "variant_current_editor#poll"
    end
    
    resource :authentication
    resources :users
    resources :user_preferences
    
    resources :sections
    resources :content_sections
    resources :content_items
    resources :link_section_links
    resources :redirects, :only => [:new]    
    
    resources :locales, :only => [:show]
    
    namespace :media do
      resources :dirs do
        # Alert! Routes hard coded in app/views/skyline/media_files/_index.html.erb        
        resources :files      
        
        match 'data/:size/:name', :to => "data#show", :via => :get, :name => /[^\/]+/, :as => :data_with_size
        match 'data/:name', :to => "data#show", :via => :get, :name => /[^\/]+/, :as => :data
      end      
    end   
  
    namespace :browser do
      resources :images
      resources :links
      resources :pages
      resources :files
      namespace :tabs do
        namespace :media_library do
          resources :media_dirs do
            resources :media_files
          end
        end
        resources :linkables        
      end         
    end
     
    namespace :content do
      namespace :editors do
        match 'editable_list/(:action(/:id))', :to => "editable_list"
        match 'joinable_list/(:action(/:id))', :to => "joinable_list"
      end
    end
    
    match 'content/(:action/(*types))', :to => "content"
     
    resources :settings, :except => [:create, :destroy]    
  end
  
  # ========================
  # = Implementation url's =
  # ========================
  #Media files data route

  # match 'media/:cache_key/:file_id/:size/:name', :to => "skyline/site/media_files_data#show", :via => :get, :name => /[^\/]+/, :cache_key => /\d{2}\/\d{2}\/\d+/
  # match 'media/:cache_key/:file_id/:name', :to => "skyline/site/media_files_data#show", :via => :get, :name => /[^\/]+/, :cache_key => /\d{2}\/\d{2}\/\d+/

  # match 'media/dirs/:dir_id/data/:size/:name', :to => "skyline/site/media_files_data#show", :via => :get, :name => /[^\/]+/
  # match 'media/dirs/:dir_id/data/:name', :to => "skyline/site/media_files_data#show", :via => :get, :name => /[^\/]+/
     
end