Rails.application.routes.draw do
  mount TwoFactorCookies::Engine => '/two_factor_cookies'

  post 'sessions/new', as: :login
  get 'sessions/destroy', as: :logout

  root 'welcome#index'
end
