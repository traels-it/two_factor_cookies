Rails.application.routes.draw do
  mount TwoFactorCookies::Engine => '/two_factor_cookies'

  post 'sessions/new', as: :login
  get 'sessions/destroy', as: :logout

  get 'users/:id/edit', to: 'users#edit', as: :edit_user

  get 'welcome/show', to: 'welcome#show', as: :show
  root to: 'welcome#index'
end
