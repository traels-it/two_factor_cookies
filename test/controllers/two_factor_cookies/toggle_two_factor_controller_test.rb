require 'test_helper'

module TwoFactorCookies
  class ToggleTwoFactorControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    let(:user) { User.create(username: 'user@email.com', password: 'password', phone: '12341234') }

    before do
      TwoFactorCookies::TextMessage.stubs(:send)
      User.stubs(:find).returns(user)
    end

    describe('#update') do
      it 'confirms a user phone number when credentials are correct' do
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(true)
        get resend_code_confirm_phone_number_path(user_id: user.id)
        patch confirm_phone_number_path(user_id: user.id), params: { confirm_phone_number: { one_time_password: '123123' } }

        assert user.reload.confirmed_phone_number?
      end

      it 'does not confirm when supplied code is incorrect' do
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(false)
        get resend_code_confirm_phone_number_path(user_id: user.id)
        patch confirm_phone_number_path(user_id: user.id), params: { confirm_phone_number: { one_time_password: '123123' } }

        assert_not user.reload.confirmed_phone_number?
      end
    end

    describe '#toggle_two_factor' do
      it 'updates the user if enable_two_factor is true' do
        patch toggle_two_factor_path(user_id: user.id), params: { user: { two_factor_enabled: '1'}, user_id: user.id}
        user.reload

        assert user.two_factor_enabled?
      end

      it 'disables two factor if enable two factor is missing' do
        user.update(confirmed_phone_number: true)

        patch toggle_two_factor_path(user_id: user.id), params: { user: { two_factor_enabled: '0'}, user_id: user.id}
        user.reload

        assert_not user.two_factor_enabled?
        assert_not user.confirmed_phone_number?
      end
    end
  end
end
