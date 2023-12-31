require 'test_helper'

module TwoFactorCookies
  class ToggleTwoFactorControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    let(:user) { User.create(username: 'username', password: 'password', phone: '+4512341234', confirmed_phone_number: false, enabled_two_factor: false) }

    before do
      TwoFactorCookies::TextMessage.stubs(:send)
    end

    describe('#update') do
      it 'confirms a user phone number when credentials are correct' do
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(true)
        get two_factor_cookies.resend_code_confirm_phone_number_path(user_id: user.id)
        patch two_factor_cookies.confirm_phone_number_path(user_id: user.id), params: { confirm_phone_number: { one_time_password: '123123' } }

        assert user.reload.confirmed_phone_number?
      end

      it 'does not confirm when supplied code is incorrect' do
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(false)
        get two_factor_cookies.resend_code_confirm_phone_number_path(user_id: user.id)
        patch two_factor_cookies.confirm_phone_number_path(user_id: user.id), params: { confirm_phone_number: { one_time_password: '123123' } }

        assert_not user.reload.confirmed_phone_number?
      end
    end

    describe '#toggle_two_factor' do
      it 'updates the user if enabled_two_factor param is true' do
        patch two_factor_cookies.toggle_two_factor_path(user_id: user.id), params: { user: { enabled_two_factor: '1'}, user_id: user.id}
        user.reload

        assert user.enabled_two_factor?
      end

      it 'disables two factor and disaffirms phone number otherwise' do
        user.update(confirmed_phone_number: true)

        patch two_factor_cookies.toggle_two_factor_path(user_id: user.id), params: { user: { enabled_two_factor: '0'}, user_id: user.id}
        user.reload

        assert_not user.enabled_two_factor?
        assert_not user.confirmed_phone_number?
      end

      it 'writes to the log, when toggling 2fa on' do
        assert_log_changes I18n.t('two_factor_cookies.logger.toggle_2fa_on', id: user.id) do
          patch two_factor_cookies.toggle_two_factor_path(user_id: user.id), params: { user: { enabled_two_factor: '1'}, user_id: user.id}
        end
      end

      it 'writes to the log, when toggling 2fa off' do
        assert_log_changes I18n.t('two_factor_cookies.logger.toggle_2fa_off', id: user.id) do
          patch two_factor_cookies.toggle_two_factor_path(user_id: user.id), params: { user: { enabled_two_factor: '0'}, user_id: user.id}
        end
      end
    end

    describe 'configurations' do
      before do
        TwoFactorCookies.configure do |config|
          config.update_params = :phone_number, :another_permitted_param
        end
      end

      after do
        TwoFactorCookies.configure do |config|
          config.update_params = nil
        end
      end

      it 'can configure additional permitted parameters' do
        skip 'I do no know how to test this'
        # patch toggle_two_factor_path(user_id: user.id), params: { user: { enabled_two_factor: '1', phone_number: '+4512341234', another_permitted_param: 'hello' }, user_id: user.id}
      end
    end
  end
end
