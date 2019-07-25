TwoFactorCookies::Engine.routes.draw do
   # two_factor_authentication
    get 'two_factor_authentication', to: 'two_factor_authentication#show', as: :show_two_factor_authentication
    patch 'two_factor_authentication', to: 'two_factor_authentication#update', as: :update_two_factor_authentication
    get 'two_factor_authentication/resend_code', to: 'two_factor_authentication#resend_code', as: :resend_code_two_factor_authentication

    # confirm_phone_number
    patch 'toggle_two_factor/:id', to: 'toggle_two_factor#update', as: :confirm_phone_number
    patch 'toggle_two_factor/:id/toggle', to: 'toggle_two_factor#toggle_two_factor', as: :toggle_two_factor
    get 'toggle_two_factor/:id/resend_code', to: 'toggle_two_factor#resend_code', as: :resend_code_confirm_phone_number
end
