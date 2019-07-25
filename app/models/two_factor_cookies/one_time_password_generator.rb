module TwoFactorCookies
  class OneTimePasswordGenerator
    class << self
      def generate_code
        seed =  Random.rand(10_000)

        { seed: seed, code: generator.at(seed) }
      end

      def verify_code(code, seed)
        !!generator.verify(code, seed)
      end

      private

        def generator
          @generator ||= ROTP::HOTP.new(TwoFactorCookies.configuration.otp_generation_secret_key)
        end
    end
  end
end
