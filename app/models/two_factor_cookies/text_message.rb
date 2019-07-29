module TwoFactorCookies
  class TextMessage
    class << self
      def send(user:, code:)
        if Rails.env.development?
          File.open(Rails.root.join('tmp', 'otp.txt'), 'w') { |file| file.write code }
        else
          client.messages.create(
            body: I18n.t('two_factor_authentication.text_message.one_time_password', code: code),
            from: TwoFactorCookies.configuration.twilio_phone_number,
            to: user.public_send(TwoFactorCookies.configuration.phone_number_field_name)
          )
        end
      end

      private

        def client
          @client = Twilio::REST::Client.new(
            TwoFactorCookies.configuration.twilio_account_sid,
            TwoFactorCookies.configuration.twilio_auth_token
          )
        end
    end
  end
end
