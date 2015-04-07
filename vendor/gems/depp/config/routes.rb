Depp::Engine.routes.draw do
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

  root 'polls#show'
end
