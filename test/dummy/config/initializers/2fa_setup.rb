TwoFactorCookies.configure do |config|
  # otp generation and verification
  config.otp_generation_secret_key = 'AXFGXT27ZK4PFSPWOD5COTZ6D56SPNYH'

  # cookie expiry
  config.two_factor_authentication_expiry = 30.days
  config.otp_expiry = 30.minutes

  # text message sending
  config.twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.twilio_phone_number = ENV['TWILIO_PHONE_NUMBER']
  config.twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']

  # user model
  # user_model_name is used as the permit option in toggle_two_factor_controller
  config.user_model_name = :user
  config.phone_number_field_name = :phone
  config.username_field_name = :username

  # controllers
  config.two_factor_authentication_success_route = :root_path
  config.toggle_two_factor_success_route = :edit_user_path
  config.confirm_phone_number_success_route = :edit_user_path
  #config.layout_path = nil
  # The method responsible for logging. If set to nil, nothing will be logged.
  config.logging_method_name = 'log'

  # In order to know which user is attempting to login, the two factor authentication controller checks current_user. It
  # looks at its parent for this method. The default parent is ApplicationController. If you use devise or have
  # implemented current_user elsewhere, you need to supply the parent constant here
  # config.two_factor_authentication_controller_parent = '::ApplicationController'

  # If you check for additional values when determining if a user is authenticated, you need to tell the controller how
  # to determine these values. Add a hash of key-value pairs here, where the key is the name, you want in the cookie,
  # the value is the method used to find whatever value you want as a string. Example:
  # { customer_no: 'current_company.customer_no' }
  # config.additional_authentication_values = nil

  # any params sent along when enabling 2fa that needs to be updated on the user model, for example a phone number
  # config.update_params = nil

  # If another engine than main_app contains the routes you want the 2fa controllers to redirect to, write the engine
  # name here as a string
  #config.engine_name = 'main_app'
end
