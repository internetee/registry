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

  namespace :registrar do
    root 'polls#show'

    resources :invoices
    resources :deposits

    devise_scope :user do
      get 'login' => 'sessions#login'
      get 'login/mid' => 'sessions#login_mid'
      post 'login/mid' => 'sessions#mid'
      post 'login/mid_status' => 'sessions#mid_status'

      post 'sessions' => 'sessions#create'
      post 'mid' => 'sessions#mid'
      get 'logout' => '/devise/sessions#destroy'
    end

    resources :domains do
      collection do
        post 'update', as: 'update'
        post 'destroy', as: 'destroy'
        get 'renew'
        match 'transfer', via: [:post, :get]
        get 'edit'
        get 'info'
        get 'check'
        get 'delete'
      end
    end

    resources :contacts do
      member do
        get 'delete'
      end

      collection do
        get 'check'
      end
    end

    resource :poll do
      collection do
        post 'confirm_keyrelay'
        post 'confirm_transfer'
      end
    end

    resource :keyrelay

    resource :xml_console do
      collection do
        get 'load_xml'
      end
    end
  end

  # ## ADMIN ROUTES
  namespace :admin do
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

  devise_for :users

  devise_scope :user do
    get 'login' => 'admin/sessions#login'
  end

  root to: redirect('admin/login')
end
