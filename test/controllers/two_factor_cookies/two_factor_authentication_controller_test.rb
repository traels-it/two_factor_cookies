require 'test_helper'

module TwoFactorCookies
  class TwoFactorAuthenticationControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    let(:user) { User.create(username: 'user@email.com', password: 'password', phone: '12341234') }

    before do
      TwoFactorCookies::TextMessage.stubs(:send)
      User.stubs(:find).returns(user)
    end

    describe '#show' do
      it 'sends a text with otp to the phone number of the user' do
        TwoFactorCookies::TextMessage.expects(:send)

        get show_two_factor_authentication_path

        assert_response :success
      end

      it 'only sends a text if there is no seed stored in cookies' do
        TwoFactorCookies::TextMessage.expects(:send)

        get show_two_factor_authentication_path
        get show_two_factor_authentication_path

        assert_response :success
      end
    end

    describe '#update' do
      let(:good_params) { { two_factor_authentication: { one_time_password: '123321' } } }

      it 'validates the user submitted one time password against the seed stored in session' do
        get show_two_factor_authentication_path
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(true)

        patch update_two_factor_authentication_path, params: good_params
      end

      it 'redirects to root on success' do
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(true)

        get show_two_factor_authentication_path
        patch update_two_factor_authentication_path, params: good_params

        assert_response :redirect
        #assert_redirected_to main_app.root_path
      end

      it 'redirects to two factor authentication show on failure and shows a error' do
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(false)

        get show_two_factor_authentication_path
        patch update_two_factor_authentication_path, params: good_params

        assert_response :redirect
        assert_redirected_to controller: 'two_factor_authentication', action: 'show'
      end
    end

    describe '#resend_code' do
      it 'generates and sends a new code' do
        TwoFactorCookies::TextMessage.expects(:send)

        get resend_code_two_factor_authentication_path

        assert_response :redirect
        assert_redirected_to controller: 'two_factor_authentication', action: 'show'
      end
    end
  end
end
