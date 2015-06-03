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

  # REGISTRAR ROUTES
  namespace :registrar do
    root 'polls#show'

    resources :invoices do
      member do
        get 'download_pdf'
        match 'forward', via: [:post, :get]
        patch 'cancel'
      end
    end

    resources :deposits
    resources :account_activities

    devise_scope :user do
      get 'login' => 'sessions#login'
      get 'login/mid' => 'sessions#login_mid'
      post 'login/mid' => 'sessions#mid'
      post 'login/mid_status' => 'sessions#mid_status'

      post 'sessions' => 'sessions#create'
      post 'id' => 'sessions#id'
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

    # turned off requested by client
    # resources :nameservers do
      # collection do
        # match 'replace_all', via: [:post, :get]
      # end
    # end

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

  # REGISTRANT ROUTES
  namespace :registrant do
    root 'domains#index'

    # resources :invoices do
      # member do
        # get 'download_pdf'
        # match 'forward', via: [:post, :get]
        # patch 'cancel'
      # end
    # end

    # resources :deposits
    # resources :account_activities

    resources :domain_update_confirms
    resources :domain_delete_confirms

    devise_scope :user do
      get 'login' => 'sessions#login'
      get 'login/mid' => 'sessions#login_mid'
      post 'login/mid' => 'sessions#mid'
      post 'login/mid_status' => 'sessions#mid_status'

      post 'sessions' => 'sessions#create'
      post 'mid' => 'sessions#mid'
      post 'id' => 'sessions#id'
      get 'logout' => '/devise/sessions#destroy'
    end

    resources :domains do
      resources :registrant_verifications
      collection do
        post 'update', as: 'update'
        post 'destroy', as: 'destroy'
        get 'renew'
        get 'edit'
        get 'info'
        get 'delete'
      end
    end

    resources :whois
    # resources :contacts do
      # member do
        # get 'delete'
      # end

      # collection do
        # get 'check'
      # end
    # end

    # resource :poll do
      # collection do
        # post 'confirm_keyrelay'
        # post 'confirm_transfer'
      # end
    # end
  end

  # ADMIN ROUTES
  namespace :admin do
    resources :keyrelays
    resources :zonefiles
    resources :zonefile_settings
    resources :legal_documents
    resources :keyrelays
    resources :pricelists

    resources :bank_statements do
      post 'bind_invoices', on: :member
      get 'download_import_file', on: :member
    end

    resources :bank_transactions do
      patch 'bind', on: :member
    end

    resources :invoices do
      patch 'cancel', on: :member
    end

    resources :domains do
      resources :domain_versions
    end

    resources :settings

    resources :registrars do
      resources :api_users
      resources :white_ips
      collection do
        get :search
      end
    end

    resources :registrants, controller: 'contacts'

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
      post 'sessions' => 'sessions#create'
      get 'logout' => '/devise/sessions#destroy'
    end

    root 'dashboards#show'
  end

  devise_for :users

  root to: redirect('admin/login')
end
