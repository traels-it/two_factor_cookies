module TwoFactorCookies
  class Configuration
    attr_accessor :otp_generation_secret_key

    def initialize
      @otp_generation_secret_key = nil
    end
  end
end
