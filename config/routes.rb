require_dependency 'epp_constraint'

Rails.application.routes.draw do
  namespace(:epp, defaults: { format: :xml }) do
    match 'session/:action', controller: 'sessions', via: :all, constraints: EppConstraint.new(:session)
    match 'session/pki/:action', controller: 'sessions', via: :all, constraints: EppConstraint.new(:session)

    post 'command/:action', controller: 'domains', constraints: EppConstraint.new(:domain)
    post 'command/:action', controller: 'contacts', constraints: EppConstraint.new(:contact)
    post 'command/poll',     to: 'polls#poll', constraints: EppConstraint.new(:poll)
    post 'command/keyrelay', to: 'keyrelays#keyrelay', constraints: EppConstraint.new(:keyrelay)

    post 'command/:command', to: 'errors#not_found', constraints: EppConstraint.new(:not_found) # fallback route

    get 'error/:command', to: 'errors#error'
    match "*command", to: 'errors#error', via: [:post, :get, :patch, :put, :delete]
  end

  mount Repp::API => '/'

  namespace :api do
    namespace :v1 do
      namespace :registrant do
        post 'auth/eid', to: 'auth#eid'

        resources :domains, only: %i[index show], param: :uuid do
          resource :registry_lock, only: %i[create destroy]
        end
        resources :contacts, only: %i[index show], param: :uuid
      end
    end
  end

  # REGISTRAR ROUTES
  namespace :registrar do
    root 'polls#show'

    devise_for :users, path: '', class_name: 'ApiUser', skip: %i[sessions]

    devise_scope :registrar_user do
      get 'login/mid' => 'sessions#login_mid'
      post 'login/mid' => 'sessions#mid'
      post 'login/mid_status' => 'sessions#mid_status'
      post 'id' => 'sessions#id'
      post 'mid' => 'sessions#mid'
    end

    resources :invoices do
      member do
        get 'download_pdf'
        match 'forward', via: [:post, :get]
        patch 'cancel'
      end
    end

    resources :deposits
    resources :account_activities

    put 'current_user/switch/:new_user_id', to: 'current_user#switch', as: :switch_current_user
    resource :profile, controller: :profile, only: :show

    resources :domains do
      collection do
        post 'update', as: 'update'
        post 'destroy', as: 'destroy'
        get 'renew'
        get 'edit'
        get 'info'
        get 'check'
        get 'delete'
        get 'search_contacts'
      end
    end
    resources :domain_transfers, only: %i[new create]
    resource :bulk_change, controller: :bulk_change, only: :new
    resource :tech_contacts, only: :update
    resource :nameservers, only: :update
    resources :contacts, constraints: {:id => /[^\/]+(?=#{ ActionController::Renderers::RENDERERS.map{|e| "\\.#{e}\\z"}.join("|") })|[^\/]+/} do
      member do
        get 'delete'
      end

      collection do
        get 'check'
        get 'download_list'
      end
    end

    resource :poll, only: %i[show destroy] do
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

    get  'pay/return/:bank'       => 'payments#back',  as: 'return_payment_with'
    post 'pay/return/:bank'       => 'payments#back'
    put  'pay/return/:bank'       => 'payments#back'
    post 'pay/callback/:bank'     => 'payments#callback', as: 'response_payment_with'
    get  'pay/go/:bank'           => 'payments#pay',   as: 'payment_with'
  end

  scope :registrar do
    devise_scope :registrar_user do
      get 'sign_in', to: 'registrar/sessions#new', as: :new_registrar_user_session

      # /registrar/sessions path is hardcoded in Apache config for certificate-based authentication
      # See https://github.com/internetee/registry/blob/master/README.md#installation
      # Client certificate is asked only on login form submission, therefore the path must be
      # different from the one in `new_registrar_user_session` route
      post 'sessions', to: 'registrar/sessions#create', as: :registrar_user_session

      delete 'sign_out', to: 'registrar/sessions#destroy', as: :destroy_registrar_user_session
    end
  end

  namespace :registrant do
    root 'domains#index'

    # POST /registrant/sign_in is not used
    devise_for :users, path: '', class_name: 'RegistrantUser'
    devise_scope :registrant_user do
      get 'login/mid' => 'sessions#login_mid'
      post 'login/mid' => 'sessions#mid'
      post 'login/mid_status' => 'sessions#mid_status'
      post 'mid' => 'sessions#mid'
      post 'id' => 'sessions#id'
    end

    resources :registrars, only: :show
    resources :contacts, only: :show
    resources :domains, only: %i[index show] do
      collection do
        get :download_list
      end

      member do
        get 'domain_verification_url'
      end
    end

    resources :domain_update_confirms, only: %i[show update]
    resources :domain_delete_confirms, only: %i[show update]
  end

  # ADMIN ROUTES
  namespace :admin do
    root 'dashboard#show'
    devise_for :users, path: '', class_name: 'AdminUser'

    resources :keyrelays
    resources :zonefiles
    resources :zones, controller: 'dns/zones', except: %i[show destroy]
    resources :legal_documents
    resources :keyrelays

    resources :prices, controller: 'billing/prices', except: %i[show destroy] do
      member do
        patch :expire
      end
    end

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

    resources :domains, except: %i[new create destroy] do
      resources :domain_versions, controller: 'domains', action: 'versions'
      resources :pending_updates
      resources :pending_deletes
      resource :force_delete, controller: 'domains/force_delete', only: %i[create destroy]
      resource :registry_lock, controller: 'domains/registry_lock', only: :destroy

      member do
        patch :keep
      end
    end

    resources :domain_versions do
      collection do
        get 'search'
      end
    end

    resources :contact_versions do
      collection do
        get 'search'
      end
    end

    resources :settings, only: %i[index create]

    resources :blocked_domains do
      member do
        get 'delete'
      end
    end
    resources :reserved_domains do
      member do
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
    resources :epp_logs
    resources :repp_logs

    authenticate :admin_user do
      mount Que::Web, at: 'que'
    end
  end

  # To prevent users seeing the default welcome message "Welcome aboard" from Rails
  root to: redirect('admin/sign_in')
end
