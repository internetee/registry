require_dependency 'epp_constraint'
require 'sidekiq/web'

Rails.application.routes.draw do
  get 'practice/index'
  get 'practice/contact'
  # https://github.com/internetee/epp_proxy#translation-of-epp-calls
  #
  # profiles
  if Rails.env.development? || Rails.env.staging?
    mount PgHero::Engine, at: "pghero"
  end

  namespace :eis_billing do
    put '/payment_status', to: 'payment_status#update', as: 'payment_status', :format => false, :defaults => { :format => 'json' }
    put '/directo_response', to: 'directo_response#update', as: 'directo_response'
    put '/e_invoice_response', to: 'e_invoice_response#update', as: 'e_invoice_response'
    post '/lhv_connect_transactions', to: 'lhv_connect_transactions#create', as: 'lhv_connect_transactions'
    resource :invoices, only: [:update]
  end

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

    constraints(EppConstraint.new(:error)) do
      controller('errors') do
        post 'command/create', to: 'errors#wrong_schema'
        post 'command/update', to: 'errors#wrong_schema'
        post 'command/info', to: 'errors#wrong_schema'
        post 'command/check', to: 'errors#wrong_schema'
        post 'command/transfer', to: 'errors#wrong_schema'
        post 'command/renew', to: 'errors#wrong_schema'
        post 'command/delete', to: 'errors#wrong_schema'
      end
    end

    post 'command/poll', to: 'polls#poll', as: 'poll', constraints: EppConstraint.new(:poll)
    get 'error/:command', to: 'errors#error'
    get 'error', to: 'errors#command_handler'
  end

  namespace :repp do
    namespace :v1 do
      resources :contacts do
        collection do
          get 'check/:id', to: 'contacts#check'
          get 'search(/:id)', to: 'contacts#search'
        end
      end

      resource :accounts, only: %i[index update] do
        collection do
          get '/', to: 'accounts#index'
          get 'balance'
          get 'details'
          post 'update_auto_reload_balance'
          get 'disable_auto_reload_balance'
        end
        member do
          put 'switch_user'
        end
      end
      resources :invoices, only: %i[index show] do
        collection do
          get ':id/download', to: 'invoices#download'
          post 'add_credit'
        end
        member do
          post 'send_to_recipient', to: 'invoices#send_to_recipient'
          put 'cancel', to: 'invoices#cancel'
        end
      end
      resources :auctions, only: %i[index]
      resources :retained_domains, only: %i[index]
      resources :stats do
        collection do
          get '/market_share_distribution', to: 'stats#market_share_distribution'
          get '/market_share_growth_rate', to: 'stats#market_share_growth_rate'
        end
      end
      namespace :registrar do
        resources :notifications, only: %i[index show update] do
          collection do
            get '/all_notifications', to: 'notifications#all_notifications'
          end
        end
        resource :accreditation, only: [:index] do
          collection do
            get '/get_info', to: 'accreditation_info#index'
            post '/push_results', to: 'accreditation_results#create'
          end
        end
        resources :nameservers do
          collection do
            put '/', to: 'nameservers#update'
          end
        end
        resources :summary, only: %i[index]
        resources :auth, only: %i[index] do
          collection do
            post '/tara_callback', to: 'auth#tara_callback'
          end
        end
        resource :xml_console, controller: 'xml_console', only: %i[create] do
          collection do
            get 'load_xml'
          end
        end
      end
      resources :domains, constraints: { id: /.*/ } do
        resources :nameservers, only: %i[index create destroy], constraints: { id: /.*/ }, controller: 'domains/nameservers'
        resources :dnssec, only: %i[index create], constraints: { id: /.*/ }, controller: 'domains/dnssec'
        resources :contacts, only: %i[index create], constraints: { id: /.*/ }, controller: 'domains/contacts'
        resources :renew, only: %i[create], constraints: { id: /.*/ }, controller: 'domains/renews'
        resources :transfer, only: %i[create], constraints: { id: /.*/ }, controller: 'domains/transfers'
        resources :statuses, only: %i[update destroy], constraints: { id: /.*/ }, controller: 'domains/statuses'
        match 'dnssec', to: 'domains/dnssec#destroy', via: 'delete', defaults: { id: nil }
        match 'contacts', to: 'domains/contacts#destroy', via: 'delete', defaults: { id: nil }
        collection do
          get ':id/transfer_info', to: 'domains#transfer_info', constraints: { id: /.*/ }
          post 'transfer', to: 'domains#transfer'
          patch 'contacts', to: 'domains/contacts#update'
          patch 'admin_contacts', to: 'domains/admin_contacts#update'
          post 'renew/bulk', to: 'domains/renews#bulk_renew'
        end
      end
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
        get 'confirms/:name/:template/:token', to: 'confirms#index', constraints: { name: /[^\/]+/ }
        post 'confirms/:name/:template/:token/:decision', to: 'confirms#update', constraints: { name: /[^\/]+/ }

        resources :domains, only: %i[index show], param: :uuid do
          resource :registry_lock, only: %i[create destroy]
        end
        resources :contacts, only: %i[index show update], param: :uuid do
          get 'do_need_update_contacts', to: 'contacts#do_need_update_contacts',
                                         as: :do_need_update_contacts
          post 'update_contacts', to: 'contacts#update_contacts', as: :update_contacts
        end
        resources :companies, only: %i[index]
      end

      namespace :accreditation_center do
        # At the moment invoice_status endpoint returns only cancelled invoices. But in future logic of this enpoint can change.
        # And it will need to return invoices of different statuses. I decided to leave the name of the endpoint "invoice_status"
        resources :invoice_status, only: [ :index ]
        resource :domains, only: [ :show ], param: :name
        resource :contacts, only: [ :show ], param: :id
        resource :results, only: [ :show ], param: :name
        # resource :auth, only: [ :index ]
        get 'show_api_user', to: 'results#show_api_user'
        get 'list_accreditated_api_users', to: 'results#list_accreditated_api_users'
        get 'auth', to: 'auth#index'
      end

      resources :auctions, only: %i[index show update], param: :uuid
      resources :contact_requests, only: %i[create update], param: :id
      resources :bounces, only: %i[create]
    end

    match '*all', controller: 'cors', action: 'cors_preflight_check', via: [:options],
                  as: 'cors_preflight_check'
  end

  # REGISTRAR ROUTES
  namespace :registrar do
    devise_for :users, path: '', class_name: 'ApiUser', skip: %i[sessions]
  end

  namespace :registrant do
    devise_for :users, path: '', class_name: 'RegistrantUser'
  end

  # ADMIN ROUTES
  namespace :admin do
    root 'dashboard#show'
    devise_for :users, path: '', class_name: 'AdminUser'

    resources :zonefiles
    resources :zones, controller: 'dns/zones', except: %i[show destroy]
    resources :legal_documents, only: :show
    resources :prices, controller: 'billing/prices', except: %i[show destroy] do
      member do
        patch :expire
      end
    end

    resources :accounts
    resources :account_activities
    resources :auctions, only: %i[index create destroy] do
      collection do
        post 'upload_spreadsheet', to: 'auctions#upload_spreadsheet', as: :upload_spreadsheet
      end
    end
    # post 'admi/upload_spreadsheet', to: 'customers#upload_spreadsheet', as: :customers_upload_spreadsheet


    resources :bank_statements do
      resources :bank_transactions
      post 'bind_invoices', on: :member
    end

    resources :bank_transactions do
      patch 'bind', on: :member
    end

    resources :invoices, except: %i[edit update destroy] do
      collection do
        post ':id/cancel_paid', to: 'invoices#cancel_paid', as: 'cancel_paid'
      end
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
        get :download
        patch :keep
      end
    end

    resources :domain_versions do
      collection do
        get 'search'
      end
    end

    resources :version_domain_versions, path: '/domain_versions' do
      collection do
        get 'search' => 'domain_versions#search', via: [:get, :post], as: :search
      end
    end

    resources :contact_versions do
      collection do
        get 'search'
      end
    end

    resources :version_contact_versions, path: '/contact_versions' do
      collection do
        get 'search' => 'contact_versions#search', via: [:get, :post], as: :search
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

      collection do
        post 'release_to_auction', to: 'reserved_domains#release_to_auction', as: 'release_to_auction'
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

      collection do
        post 'set_test_date', to: 'registrars#set_test_date', as: 'set_test_date'
        post 'remove_test_date', to: 'registrars#remove_test_date', as: 'remove_test_date'
        post 'set_test_date_to_api_user', to: 'api_users#set_test_date_to_api_user', as: 'set_test_date_to_api_user'
        post 'remove_test_date_to_api_user', to: 'api_users#remove_test_date_to_api_user', as: 'remove_test_date_to_api_user'
      end
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
    resources :mass_actions, only: %i[index create]
    resources :bounced_mail_addresses, only: %i[index show destroy]

    authenticate :admin_user do
      mount Sidekiq::Web, at: 'sidekiq'
    end
  end

  # To prevent users seeing the default welcome message "Welcome aboard" from Rails
  root to: redirect('admin/sign_in')
end
