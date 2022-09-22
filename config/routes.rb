Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace 'api' do
    namespace 'v1' do
      resources :users

      post 'sign_in', to: 'authentication#sign_in'
      delete 'sign_out', to: 'authentication#sign_out'
    end
  end
end
