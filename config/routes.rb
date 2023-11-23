Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
   }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :posts
  post '/email_otps', to: 'email_otps#create'
  post '/email_otps/otp_confirmation', to: 'email_otps#otp_confirmation'
  post '/profiles/change_password', to: 'profiles#change_password'
end
