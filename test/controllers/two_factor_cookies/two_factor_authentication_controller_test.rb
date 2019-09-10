require 'test_helper'

module TwoFactorCookies
  class TwoFactorAuthenticationControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    let(:user) { User.create(username: 'user@email.com', password: 'password', phone: '12341234', confirmed_phone_number: true, enabled_two_factor: true) }

    before do
      TwoFactorCookies::TextMessage.stubs(:send)
    end

    describe '#show' do
      it 'sends a text with otp to the phone number of the user' do
        TwoFactorCookies::TextMessage.expects(:send)

        login user
        follow_redirect!

        assert_response :success
      end

      it 'only sends a text if there is no seed stored in cookies' do
        TwoFactorCookies::TextMessage.expects(:send)
        login user

        get two_factor_cookies.show_two_factor_authentication_path

        assert_response :success
      end
    end

    describe '#update' do
      before do
        login user
        follow_redirect!
      end

      let(:good_params) { { two_factor_authentication: { one_time_password: '123321' } } }

      it 'validates the user submitted one time password against the seed stored in session' do
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(true)

        patch two_factor_cookies.update_two_factor_authentication_path, params: good_params
      end

      it 'redirects to root on success' do
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(true)

        patch two_factor_cookies.update_two_factor_authentication_path, params: good_params

        assert_response :redirect
        #assert_redirected_to main_app.root_path
      end

      it 'redirects to two factor authentication show on failure and shows a error' do
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(false)

        patch two_factor_cookies.update_two_factor_authentication_path, params: good_params

        assert_response :redirect
        assert_redirected_to two_factor_cookies.show_two_factor_authentication_path
      end
    end

    it 'does not attempt to parse an unexisting mfa cookie' do
      TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).never

      patch two_factor_cookies.update_two_factor_authentication_path, params: { two_factor_authentication: { one_time_password: '123321' } }
    end

    describe '#resend_code' do
      before do
        login user
        follow_redirect!
      end

      it 'generates and sends a new code' do
        TwoFactorCookies::TextMessage.expects(:send)

        get two_factor_cookies.resend_code_two_factor_authentication_path

        assert_response :redirect
        assert_redirected_to two_factor_cookies.show_two_factor_authentication_path
      end
    end

    describe 'standard inheritance' do
      it 'inherits from ApplicationController as standard' do
        assert_equal ApplicationController, TwoFactorCookies::TwoFactorAuthenticationController.superclass
      end
    end

    describe 'configured inheritance' do
      before do
        TwoFactorCookies.configure do |config|
          config.two_factor_authentication_controller_parent = AnotherApplicationController
        end
      end

      after do
        TwoFactorCookies.configure do |config|
          config.two_factor_authentication_controller_parent = ApplicationController
        end
      end

      it 'inherits from the class it is configured to' do
        skip 'this test only works when running on its own'
        assert_equal AnotherApplicationController, TwoFactorCookies::TwoFactorAuthenticationController.superclass
      end
    end

    describe 'it places any additional authentication values defined in configuration in the mfa cookie' do
      let(:good_params) { { two_factor_authentication: { one_time_password: '123321' } } }

      before do
        login user
        follow_redirect!
        TwoFactorCookies.configure do |config|
          config.additional_authentication_values = { customer_no: 'current_company.customer_no' }
        end
      end

      after do
        TwoFactorCookies.configure do |config|
          config.additional_authentication_values = nil
        end
      end

      it 'is not automatically tested, because I do not know how, as integration tests have no access to the cookies...' do
        TwoFactorCookies::OneTimePasswordGenerator.expects(:verify_code).returns(true)

        patch two_factor_cookies.update_two_factor_authentication_path, params: good_params
      end
    end
  end
end
