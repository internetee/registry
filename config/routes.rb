require 'epp_constraint'

Rails.application.routes.draw do
  namespace(:epp, defaults: { format: :xml }) do
    match 'session/:action', controller: 'sessions', via: :all
    match 'session/pki/:action', controller: 'sessions', via: :all

    post 'command/:action', controller: 'domains', constraints: EppConstraint.new(:domain)
    post 'command/:action', controller: 'contacts', constraints: EppConstraint.new(:contact)
    post 'command/poll', to: 'polls#poll', constraints: EppConstraint.new(:poll)
    post 'command/keyrelay', to: 'keyrelays#keyrelay', constraints: EppConstraint.new(:keyrelay)

    post 'command/:command', to: 'errors#not_found' # fallback route

    get 'error/:command', to: 'errors#error'
  end

  mount Repp::API => '/'

  ## ADMIN ROUTES
  namespace(:admin) do
    resources :keyrelays

    resources :zonefiles

    resources :zonefile_settings

    resources :legal_documents

    resources :keyrelays

    resources :domains do
      resources :domain_versions
    end

    resources :settings
    resources :registrars do
      collection do
        get :search
      end
    end

    resources :contacts do
      collection do
        get 'search'
      end
    end

    resources :admin_users
    resources :api_users do
      resources :certificates do
        member do
          post 'sign'
          post 'revoke'
          get 'download_csr'
          get 'download_crt'
        end
      end
    end

    resources :delayed_jobs

    resource :dashboard

    resources :epp_logs
    resources :repp_logs

    devise_scope :user do
      get 'login' => 'sessions#login'
      # get 'login/mid' => 'sessions#login_mid'
      # post 'login/mid' => 'sessions#mid'

      post 'sessions' => 'sessions#create'
      post 'mid' => 'sessions#mid'
      get 'logout' => '/devise/sessions#destroy'
    end

    root 'dashboards#show'
  end

  namespace(:registrar) do
    resources :invoices

    devise_scope :user do
      get 'login' => 'sessions#login'
      get 'login/mid' => 'sessions#login_mid'
      post 'login/mid' => 'sessions#mid'
      post 'login/mid_status' => 'sessions#mid_status'

      post 'sessions' => 'sessions#create'
      post 'mid' => 'sessions#mid'
      get 'logout' => '/devise/sessions#destroy'
    end

    # authenticated :user do
    #   root to: 'domains#index', as: :authenticated_root
    # end

    root to: redirect('/registrar/depp')
  end

  mount Depp::Engine, at: '/registrar/depp', as: 'depp'

  devise_for :users

  devise_scope :user do
    get 'login' => 'admin/sessions#login'
  end

  root to: redirect('login')

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'admin/domains#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
