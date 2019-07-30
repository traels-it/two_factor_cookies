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

    describe 'user' do
      it 'uses current_user if current_user exists' do
        ApplicationController.any_instance.stubs(:current_user).returns(user)
        TwoFactorCookies::TwoFactorAuthenticationController.any_instance.expects(:user_model).never
        login user
        follow_redirect!

        get two_factor_cookies.show_two_factor_authentication_path

        assert_response :success
      end

      it 'looks in the session for user_id or unauthenticated_id, when there is no current_user' do
        TwoFactorCookies::TwoFactorAuthenticationController.any_instance.expects(:user_model).returns(User)
        login user
        follow_redirect!

        assert_response :success
      end
    end

    describe 'it handles namespaced user models' do
      let(:user) { Namespace::User.create(username: 'user@email.com', password: 'password', phone: '12341234', confirmed_phone_number: true, enabled_two_factor: true) }

      before do
        TwoFactorCookies.configure do |config|
          config.user_model_namespace = 'Namespace'
          config.user_model_name = :user
        end
      end

      after do
        TwoFactorCookies.configure do |config|
          config.user_model_namespace = nil
          config.user_model_name = :user
        end
      end

      it 'calls the namespaced user model' do
        Namespace::User.stubs(:find).returns(user)
        Namespace::User.any_instance.expects(:phone).returns(user.phone)

        get show_two_factor_authentication_path

        assert_response :success
      end
    end
  end
end
