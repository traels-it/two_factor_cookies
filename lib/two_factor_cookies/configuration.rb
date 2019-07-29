module TwoFactorCookies
  class Configuration
    attr_accessor :otp_generation_secret_key, :two_factor_authentication_success_route, :confirm_phone_number_success_route, :toggle_two_factor_success_route,
      :two_factor_authentication_expiry, :otp_expiry

    def initialize
      @otp_generation_secret_key = nil
      @two_factor_authentication_success_route = nil
      @toggle_two_factor_success_route = nil
      @confirm_phone_number_success_route = nil
      @two_factor_authentication_expiry = nil
      @otp_expiry = nil
    end
  end
end
