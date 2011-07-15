Rails.application.routes.draw do
  namespace :skyline do
    root :to => "articles#index", :type => "skyline/page"
    
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
      resources :published_publication
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
         
        match 'data/:size/:name.:format' => "data#show", :via => :get
        match 'data/:name.:format' => "data#show", :via => :get        
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
end