Rails.application.routes.draw do
  # JSON format alias
  json = { format: 'json' }

  # Devise routes
  devise_for :users, skip: [:sessions, :registrations, :confirmations, :unlocks, :passwords]

  devise_scope :user do
    post 'users/sign_in'   => 'users/sessions#create',      defaults: json # Still need to
    post 'users/password'  => 'users/passwords#create',     defaults: json # find another better solution
    put 'users/password'   => 'users/passwords#update',     defaults: json # with these defaults
    patch 'users/password' => 'users/passwords#update',     defaults: json
    post 'users'           => 'users/registrations#create', defaults: json
  end

  root 'application#root'
end
