module TwoFactorCookies
  class TextMessage
    class << self
      def send(customer:, code:)
        if Rails.env.development?
          File.open(Rails.root.join('tmp', 'otp.txt'), 'w') { |file| file.write code }
        else
          client.messages.create(
            body: I18n.t('two_factor_authentication.text_message.one_time_password', code: code),
            from: ENV['TWILIO_PHONE_NUMBER'],
            to: customer.telefon
          )
        end
      end

      private

        def client
          @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
        end
    end
  end
end
