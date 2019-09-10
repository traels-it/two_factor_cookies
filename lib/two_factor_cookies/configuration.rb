module TwoFactorCookies
  class Configuration
    attr_accessor :otp_generation_secret_key, :two_factor_authentication_success_route, :confirm_phone_number_success_route,
      :toggle_two_factor_success_route, :two_factor_authentication_expiry, :otp_expiry, :twilio_account_sid,
      :twilio_phone_number, :twilio_auth_token, :phone_number_field_name, :user_model_name, :username_field_name,
      :two_factor_authentication_controller_parent, :skip_before_action, :layout_path, :additional_authentication_values,
      :update_params, :engine_name, :logging_method_name

    def initialize
      @otp_generation_secret_key = nil
      @two_factor_authentication_expiry = 30.days
      @otp_expiry = 30.minutes

      @twilio_account_sid = nil
      @twilio_phone_number = nil
      @twilio_auth_token = nil

      @user_model_name = :user
      @phone_number_field_name = :phone_number
      @username_field_name = :username

      @two_factor_authentication_success_route = nil
      @toggle_two_factor_success_route = nil
      @confirm_phone_number_success_route = nil
      @layout_path = nil
      @two_factor_authentication_controller_parent = '::ApplicationController'
      @logging_method_name = nil

      @additional_authentication_values = {}

      @update_params = nil
      @engine_name = 'main_app'
    end
  end
end
