TwoFactorCookies.configure do |config|
  config.otp_generation_secret_key = 'AXFGXT27ZK4PFSPWOD5COTZ6D56SPNYH'
  config.two_factor_authentication_success_route = :root_path
  config.toggle_two_factor_success_route = :edit_user_path
  config.confirm_phone_number_success_route = :edit_user_path
  config.two_factor_authentication_expiry = 30.days.from_now
  config.otp_expiry = 30.minutes.from_now
end
