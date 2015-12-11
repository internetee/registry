require 'epp_constraint'

Rails.application.routes.draw do
  namespace(:epp, defaults: { format: :xml }) do
    match 'session/:action', controller: 'sessions', via: :all, constraints: EppConstraint.new(:session)
    match 'session/pki/:action', controller: 'sessions', via: :all, constraints: EppConstraint.new(:session)

    post 'command/:action', controller: 'domains', constraints: EppConstraint.new(:domain)
    post 'command/:action', controller: 'contacts', constraints: EppConstraint.new(:contact)
    post 'command/poll', to: 'polls#poll', constraints: EppConstraint.new(:poll)
    post 'command/keyrelay', to: 'keyrelays#keyrelay', constraints: EppConstraint.new(:keyrelay)

    post 'command/:command', to: 'errors#not_found', constraints: EppConstraint.new(:not_found) # fallback route

    get 'error/:command', to: 'errors#error'
  end

  mount Repp::API => '/'

  # REGISTRAR ROUTES
  namespace :registrar do
    resource :dashboard
    root 'dashboard#show'

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
      get 'switch_user/:id' => 'sessions#switch_user'
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
        get 'search_contacts'
      end
    end

    # turned off requested by client
    # resources :nameservers do
      # collection do
        # match 'replace_all', via: [:post, :get]
      # end
    # end

    resources :contacts, constraints: {:id => /[^\/]+(?=#{ ActionController::Renderers::RENDERERS.map{|e| "\\.#{e}\\z"}.join("|") })|[^\/]+/} do
      member do
        get 'delete'
      end

      collection do
        get 'check'
        get 'download_list'
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


    get  'pay/return/:bank' => 'payments#back',  as: 'return_payment_with'
    post 'pay/return/:bank' => 'payments#back'
    get  'pay/go/:bank'     => 'payments#pay',   as: 'payment_with'
  end

  # REGISTRANT ROUTES
  namespace :registrant do
    root 'domains#index'

    resources :domains do
      collection do
        get :download_list
      end
    end

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

    resources :registrars do
      resources :api_users
      resources :white_ips
      collection do
        get :search
      end
    end

    resources :registrants

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
    resources :mail_templates
    resources :account_activities

    resources :bank_statements do
      resources :bank_transactions
      collection do
        get 'import'
        post 'create_from_import'
      end

      post 'bind_invoices', on: :member
      get 'download_import_file', on: :member
    end

    resources :bank_transactions do
      patch 'bind', on: :member
    end

    resources :invoices do
      get 'download_pdf'
      patch 'cancel', on: :member
      match 'forward', via: [:post, :get]
    end

    resources :domains do
      resources :domain_versions
      resources :pending_updates
      resources :pending_deletes
      member do
        post 'set_force_delete'
        post 'unset_force_delete'
      end
    end

    resources :settings

    resources :blocked_domains
    resources :reserved_domains

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

    authenticate :user do
      mount Que::Web, at: 'que'
    end

    root 'dashboards#show'
  end

  devise_for :users

  root to: redirect('admin/login')
end
