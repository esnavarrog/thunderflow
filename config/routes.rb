Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  root to: "welcome#index" # for init page in users/sign_in
  # root to: 'pages#landpage'
  resources :branches, path: 'sucursales'
  resources :resources, path: 'recursos'
  resources :integrations, path: 'integraciones'
  resources :companies, path: 'empresas' do
    resources :branches
    resources :user_accesses
    resources :resources
    resources :integrations
    post :switch_current_company, on: :collection
    get :new_first_company, on: :collection
  end

  resources :user_accesses
  resources :welcome, path: 'dashboard'
  resources :welcome do
    resources :companies
    resources :branches
    resources :deliveries
  end
  resources :deliveries, path: 'solicitudes'
  resources :statuses
  resources :commune_prices, path: 'precios_comunas'
  resources :additional_fees, path: 'adicionales'
  resources :branches do
    resources :deliveries
    resources :integrations do
      get :load_orders, on: :collection
    end
  end
  resources :financials, path: 'utilidades'
  resources :prices, path: 'precios'
  resources :tools, path: 'herramientas'
  resources :deals, path: 'cobros'
  resources :payments, path: 'pagos'
  resources :deals do
    resources :companies
    resources :payments
  end
  resources :tracking, path: 'seguimiento'
  resources :profiles, path: 'perfiles'
  resources :profiles do
    get :paginate_profiles, on: :collection
  end
  resources :map_view_routes, path: 'rutas'
  resources :archives
  resources :withdrawal_receipts, path: 'retiros'
  resources :administrative_areas, only: [] do
    collection do
      get :communes
    end
  end
  resources :default_profile_prices, only: [:create]

  # resources :users, only:[:index, :show, :update]
  get 'get_deliver', to: 'branches#get_deliver'
  get 'new_deliver', to: 'deliveries#new_deliver'
  get 'communes', to: 'branches#communes'
  get 'request_xlsx', to: 'deliveries#request_xlsx'
  get 'select_date', to: 'deliveries#select_date'
  post 'create_deliveries', to: 'deliveries#create_deliveries'
  get 'edit_user_role', to: 'users#edit_user_role'
  get 'asign_user_to_delivery', to: 'deliveries#asign_user_to_delivery'
  get 'asign_user', to: 'deliveries#asign_user'
  get 'asign_massive', to: 'deliveries#asign_massive'
  get 'change_massive_status', to: 'statuses#change_massive_status'
  get 'tracking_status', to: 'tracking#tracking_status'
  get 'report_form', to: 'welcome#report_form'
  get 'report_for_pay', to: 'welcome#report_for_pay'
  get 'select_company', to: 'deals#select_company'
  get 'get_result_prices', to: 'deals#get_result_prices'
  put 'save_prices', to: 'deliveries#save_prices'
  get 'rejected_pay', to: 'deals#rejected_pay'
  get 'download_deliveries', to: 'deliveries#download_deliveries'
  get 'xlsx_of_branches', to: 'companies#xlsx_of_branches'
  get 'open_modal_download', to: 'deliveries#open_modal_download'
  get 'download_for_ids', to: 'deliveries#download_for_ids'
  get 'open_modal_ids', to: 'deliveries#open_modal_ids'
  get 'deals/:id/payed', to: 'deals#payed', as: 'payed'
  put 'delivery_null_deal', to: 'deliveries#delivery_null_deal'
  get 'price_for_distance', to: 'deliveries#price_for_distance'
  get 'request_api_for_client', to: 'companies#request_api_for_client'
  get 'active_api', to: 'companies#active_api'
  get 'branch_address', to: 'branches#branch_address'
  get 'see_secret_key', to: 'companies#see_secret_key'
  get 'export_deliveries', to: 'deals#export_deliveries'
  get 'charts_welcome', to: 'welcome#charts_welcome'
  get 'charts_company', to: 'companies#charts_company'
  get 'download_deliveries_deal', to: 'deals#download_deliveries_deal'
  get 'download_deliveries_price', to: 'prices#download_deliveries_price'
  put 'up_deliveries_deal', to: 'deals#up_deliveries_deal'
  put 'up_deliveries_price', to: 'prices#up_deliveries_price'
  get 'report_for_client', to: 'companies#report_for_client'
  get 'report_client', to: 'companies#report_client'
  get 'new_contact', to: 'pages#new_contact'
  get 'contact', to: 'pages#contact'
  get 'metrics', to: 'welcome#metrics'
  get 'download_deliver_asigned', to: 'profiles#download_deliver_asigned'
  get 'change_status_delivery', to: 'deliveries#change_status_delivery'
  get 'upload_files/:deal_id', to: 'deals#upload_files', as: 'upload_files'
  put 'update_archives/:id', to: 'deals#update_archives', as: 'update_archives'
  put 'send_notification/:deal_id', to: 'deals#send_notification', as: 'send_notification'
  get 'send_email/:withdrawal_receipt_id', to: 'withdrawal_receipts#send_email', as: 'send_email'
  get 'price_deliveries', to: 'administrative_areas#price_deliveries'
  put 'update_settings_company/:company_id', to: 'companies#update_settings_company', as: 'update_settings_company'
  get 'confirmed_profile/:id', to: 'profiles#confirmed_profile', as: 'confirmed_profile'
  get 'get_pending_deliveries', to: 'welcome#get_pending_deliveries'


  get 'landpage', to: 'pages#landpage'

  #WebPay
  get '/webpay/webpay_final_url', to: 'webpay#webpay_final_url'
  # post '/webpay/webpay_return_url', :to => 'webpay#webpay_return_url', :as => :webpay_return_url
  # get '/webpay/webpay_return_url', :to => 'webpay#webpay_return_url'
  post '/pagos/success_final', to: 'payments#success_final', as: :success_final
  post 'pagos/success', to: 'payments#pay_success', as: :pay_success
  get 'pagos/pago_realizado', to: 'payments#pay_aproved', as: :pago_realizado
  get 'pagos/pago_rechazado', to: 'payments#pay_rejected', as: :pago_rechazado
  get 'webpay/error', to: 'payments#webpay_error', as: :webpay_error
  get 'webpay/nullify', to: 'payments#webpay_nullify', as: :webpay_nullify
  get 'show_table', to: 'deliveries#show_table'

  # setup API

  get 'api_docs_index', to: redirect('/api-docs/index.html')
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :deliveries
      post 'login', to: 'authentication#create'
      post 'auth/google_login', to: 'authentication#google_login'
      delete 'logout', to: 'authentication#destroy'
      get 'me', to: 'users#me'
      resources :driver_positions, only: [:create]
    end
  end

  if Rails.env.development? || ENV['DEV_ENV'] == 'staging'
    devise_scope :user do
      post 'sessions/switch', to: 'users/sessions#switch'
    end
  end
end
