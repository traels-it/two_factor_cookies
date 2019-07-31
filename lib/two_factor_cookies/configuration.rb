module TwoFactorCookies
  class Configuration
    attr_accessor :otp_generation_secret_key, :two_factor_authentication_success_route, :confirm_phone_number_success_route,
      :toggle_two_factor_success_route, :two_factor_authentication_expiry, :otp_expiry, :twilio_account_sid,
      :twilio_phone_number, :twilio_auth_token, :phone_number_field_name, :user_model_name, :user_model_namespace, :username_field_name,
      :two_factor_authentication_controller_parent, :skip_before_action, :layout_path, :additional_authentication_values

    def initialize
      @otp_generation_secret_key = nil
      @two_factor_authentication_expiry = 30.days.from_now
      @otp_expiry = 30.minutes.from_now

      @twilio_account_sid = nil
      @twilio_phone_number = nil
      @twilio_auth_token = nil

      @user_model_namespace = nil
      @user_model_name = :user
      @phone_number_field_name = :phone_number
      @username_field_name = :username

      @two_factor_authentication_success_route = nil
      @toggle_two_factor_success_route = nil
      @confirm_phone_number_success_route = nil
      @skip_before_action = false
      @layout_path = nil
      @two_factor_authentication_controller_parent = ::ApplicationController

      @additional_authentication_values = nil
    end
  end
end
