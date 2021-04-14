Rails.application.routes.draw do


  devise_for :users
  match "/403", to: "errors#error_403", via: :all
  match "/404", to: "errors#error_404", via: :all
  match "/422", to: "errors#error_422", via: :all
  match "/500", to: "errors#error_500", via: :all

  #match 'vendor/home', to: 'vendor#index', via: [:get, :post], as: vendor_home_page
  #match 'admin/home', to: 'admin#index', via: [:get, :post], as: vendor_home_page

  get :ie_warning, to: 'errors#ie_warning'
  get :javascript_warning, to: 'errors#javascript_warning'

  get "vendor/home" => "vendors#index"

  
  get "login", to: "login#index"
  get "request", to: "request#index"

  get "admin/home", to: "admins#index"
  get "admin/settings", to: "admins#settings"
  
  get "admin/tasks", to: "tasks#index"

  get "assessments/index", to: "assessments#index"

  root to: "pages#home"

  resources :vendors
  resources :admins
  resources :tasks

  resources :request do
    post :create, on: :collection
  end

  

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
