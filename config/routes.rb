require 'epp_constraint'

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
      delete 'logout', to: '/devise/sessions#destroy', as: :destroy_user_session
    end

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
    get 'registrar/nameservers', to: 'registrar_nameservers#edit', as: :edit_registrar_nameserver
    put 'registrar/nameservers', to: 'registrar_nameservers#update', as: :update_registrar_nameserver

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

    get  'pay/return/:bank'       => 'payments#back',  as: 'return_payment_with'
    post 'pay/return/:bank'       => 'payments#back'
    put  'pay/return/:bank'       => 'payments#back'
    post 'pay/callback/:bank'     => 'payments#callback', as: 'response_payment_with'
    get  'pay/go/:bank'           => 'payments#pay',   as: 'payment_with'
  end

  namespace :registrant do
    root 'domains#index'

    resources :domains, only: %i[index show] do
      collection do
        get :download_list
      end

      member do
        get 'domain_verification_url'
      end
    end

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
      collection do
        get :search
      end
    end

    resources :contacts
  end


  # ADMIN ROUTES
  namespace :admin do
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

    resources :domains do
      resources :domain_versions, controller: 'domains', action: 'versions'
      resources :pending_updates
      resources :pending_deletes
      resource :force_delete, controller: 'domains/force_delete', only: %i[create destroy]
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
