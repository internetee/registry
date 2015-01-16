class EppConstraint
  OBJECT_TYPES = {
    domain: { domain: 'urn:ietf:params:xml:ns:domain-1.0' },
    contact: { contact: 'urn:ietf:params:xml:ns:contact-1.0' }
  }

  def initialize(type)
    @type = type
  end

  # creates parsed_frame, detects epp request object
  def matches?(request)
    parsed_frame = Nokogiri::XML(request.params[:raw_frame])

    unless [:keyrelay, :poll].include?(@type)
      element = "//#{@type}:#{request.params[:action]}"
      return false if parsed_frame.xpath("#{element}", OBJECT_TYPES[@type]).none?
    end

    request.params[:parsed_frame] = parsed_frame.remove_namespaces!
    request.params[:epp_object_type] = @type
    true
  end
end

Rails.application.routes.draw do
  namespace(:epp, defaults: { format: :xml }) do
    match 'session/:action', controller: 'sessions', via: :all

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
    resources :domains
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

    resources :users
    resources :epp_users
    resources :domain_versions

    resources :delayed_jobs

    resource :dashboard

    resources :epp_logs
    resources :repp_logs

    root 'domains#index'
  end

  devise_for :users

  devise_scope :user do
    resources :sessions

    get 'logout' => 'devise/sessions#destroy'
    get 'login' => 'sessions#login'
  end

  authenticated :user do
    root to: 'admin/domains#index', as: :authenticated_root
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
