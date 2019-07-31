TwoFactorCookies.configure do |config|
  # otp generation and verification
  config.otp_generation_secret_key = 'AXFGXT27ZK4PFSPWOD5COTZ6D56SPNYH'

  # cookie expiry
  config.two_factor_authentication_expiry = 30.days.from_now
  config.otp_expiry = 30.minutes.from_now

  # text message sending
  config.twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.twilio_phone_number = ENV['TWILIO_PHONE_NUMBER']
  config.twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']

  # user model
  # config.user_model_namespace = nil
  config.user_model_name = :user
  config.phone_number_field_name = :phone
  config.username_field_name = :username

  # controllers
  config.two_factor_authentication_success_route = :root_path
  config.toggle_two_factor_success_route = :edit_user_path
  config.confirm_phone_number_success_route = :edit_user_path
  config.skip_before_action = true
  # In order to know which user is attempting to login, the two factor authentication controller checks current_user. It
  # looks at its parent for this method. The default parent is ApplicationController. If you use devise or have
  # implemented current_user elsewhere, you need to supply the parent constant here
  # config.two_factor_authentication_controller_parent = ApplicationController
end
