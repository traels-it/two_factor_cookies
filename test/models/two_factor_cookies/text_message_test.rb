require 'test_helper'

module TwoFactorCookies
  class TextMessageTest < ActiveSupport::TestCase
    let(:user) { User.create(username: 'username', password: 'password', phone: '+4512341234', confirmed_phone_number: false, enabled_two_factor: false) }

    describe '#send' do
      it 'calls twilio' do
        Twilio::REST::Client.any_instance.expects(:messages).returns(stub(create: ''))

        TwoFactorCookies::TextMessage.send(code: '123123', user: user)
      end
    end
  end
end
