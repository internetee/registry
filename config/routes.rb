require_dependency 'epp_constraint'

Rails.application.routes.draw do
  # https://github.com/internetee/epp_proxy#translation-of-epp-calls
  namespace :epp do
    constraints(EppConstraint.new(:session)) do
      get 'session/hello', to: 'sessions#hello', as: 'hello'
      post 'session/login', to: 'sessions#login', as: 'login'
      post 'session/logout', to: 'sessions#logout', as: 'logout'
    end

    constraints(EppConstraint.new(:contact)) do
      controller('contacts') do
        post 'command/create', action: 'create', as: :create
        post 'command/update', action: 'update', as: :update
        post 'command/info', action: 'info', as: :info
        post 'command/check', action: 'check', as: :check
        post 'command/transfer', action: 'transfer', as: :transfer
        post 'command/renew', action: 'renew', as: :renew
        post 'command/delete', action: 'delete', as: :delete
      end
    end

    constraints(EppConstraint.new(:domain)) do
      controller('domains') do
        post 'command/create', action: 'create', as: nil
        post 'command/update', action: 'update', as: nil
        post 'command/info', action: 'info', as: nil
        post 'command/check', action: 'check', as: nil
        post 'command/transfer', action: 'transfer', as: nil
        post 'command/renew', action: 'renew', as: nil
        post 'command/delete', action: 'delete', as: nil
      end
    end

    post 'command/poll', to: 'polls#poll', as: 'poll', constraints: EppConstraint.new(:poll)
    get 'error/:command', to: 'errors#error'
  end

  mount Repp::Api => '/'

  namespace :repp do
    namespace :v1 do
      resources :auctions, only: %i[index]
      resources :retained_domains, only: %i[index]
    end
  end

  match 'repp/v1/*all',
        controller: 'api/cors',
        action: 'cors_preflight_check',
        via: [:options],
        as: 'repp_cors_preflight_check'

  namespace :api do
    namespace :v1 do
      namespace :registrant do
        post 'auth/eid', to: 'auth#eid'

        resources :domains, only: %i[index show], param: :uuid do
          resource :registry_lock, only: %i[create destroy]
        end
        resources :contacts, only: %i[index show update], param: :uuid
      end

      resources :auctions, only: %i[index show update], param: :uuid
    end

    match '*all', controller: 'cors', action: 'cors_preflight_check', via: [:options],
      as: 'cors_preflight_check'
  end

  # REGISTRAR ROUTES
  namespace :registrar do
    root 'polls#show'

    devise_for :users, path: '', class_name: 'ApiUser', skip: %i[sessions]

    devise_scope :registrar_user do
      get 'login/mid' => 'sessions#login_mid'
      post 'login/mid' => 'sessions#mid'
      post 'login/mid_status' => 'sessions#mid_status'

      # /registrar/id path is hardcoded in Apache config for authentication with Estonian ID-card
      post 'id' => 'sessions#id_card', as: :id_card_sign_in

      post 'mid' => 'sessions#mid'
    end

    resources :invoices, except: %i[new create edit update destroy] do
      resource :delivery, controller: 'invoices/delivery', only: %i[new create]

      member do
        get 'download'
        patch 'cancel'
      end
    end

    resources :deposits
    resources :account_activities

    put 'current_user/switch/:new_user_id', to: 'current_user#switch', as: :switch_current_user
    resource :account, controller: :account, only: %i[show edit update]

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
        get 'remove_hold'
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
      end
    end

    resource :poll, only: %i[show destroy] do
      collection do
        post 'confirm_transfer'
      end
    end

    resource :xml_console do
      collection do
        get 'load_xml'
      end
    end

    get  'pay/return/:payment_order' => 'payments#back', as: 'return_payment_with'
    post 'pay/return/:payment_order' => 'payments#back'
    put  'pay/return/:payment_order' => 'payments#back'
    post 'pay/callback/:payment_order' => 'payments#callback', as: 'response_payment_with'
    get  'pay/go/:bank' => 'payments#pay', as: 'payment_with'

    namespace :settings do
      resource :balance_auto_reload, controller: :balance_auto_reload, only: %i[edit update destroy]
    end
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

      # /registrant/id path is hardcoded in Apache config for authentication with Estonian ID-card
      # Client certificate is asked only on login form submission, therefore the path must be different from the one in
      # `new_registrant_user_session_path` route, in case some other auth type will be implemented
      post 'id' => 'sessions#create', as: :id_card_sign_in
    end

    resources :registrars, only: :show
    resources :domains, only: %i[index show] do
      resources :contacts, only: %i[show edit update]
      member do
        get 'confirmation'
      end
    end

    resources :domain_update_confirms, only: %i[show update]
    resources :domain_delete_confirms, only: %i[show update]
  end

  # ADMIN ROUTES
  namespace :admin do
    root 'dashboard#show'
    devise_for :users, path: '', class_name: 'AdminUser'

    resources :zonefiles
    resources :zones, controller: 'dns/zones', except: %i[show destroy]
    resources :legal_documents
    resources :prices, controller: 'billing/prices', except: %i[show destroy] do
      member do
        patch :expire
      end
    end

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

    resources :invoices, except: %i[edit update destroy] do
      resource :delivery, controller: 'invoices/delivery', only: %i[new create]

      member do
        get 'download'
        patch 'cancel'
      end
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
    resources :disputes do
      member do
        get 'delete'
      end
    end

    resources :registrars do
      resources :api_users, except: %i[index]
      resources :white_ips
    end

    resources :contacts do
      collection do
        get 'search'
      end
    end

    resources :admin_users
    # /admin/api_users is mainly for manual testing
    resources :api_users, only: [:index, :show] do
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
