Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'document/ask'
      get 'document/ask_what_to_ask'
      get 'document/get_random_past_question'
    end
  end
  root 'home#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
