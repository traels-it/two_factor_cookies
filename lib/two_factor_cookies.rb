require "two_factor_cookies/configuration"
require "two_factor_cookies/engine"
require "rotp"

module TwoFactorCookies
  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
