module TwoFactorCookies
  class Configuration
    attr_accessor :otp_generation_secret_key, :two_factor_success_route, :confirm_phone_number_success_route

    def initialize
      @otp_generation_secret_key = nil
    end
  end
end
