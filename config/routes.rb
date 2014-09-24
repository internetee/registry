Rails.application.routes.draw do
  namespace(:epp) do
    match 'session/:command', to: 'sessions#proxy', defaults: { format: :xml }, via: [:get, :post]
    match 'command/:command', to: 'commands#proxy', defaults: { format: :xml }, via: [:post, :get]
    get 'error/:command', to: 'errors#error', defaults: { format: :xml }
  end

  namespace(:admin) do
    resources :domains
    resources :setting_groups
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
  end

  namespace(:client) do
    resources :domains
    resources :domain_transfers do
      member do
        post 'approve'
      end
    end

    resources :contacts do
      collection do
        get 'search'
      end
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'admin/domains#index'

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
