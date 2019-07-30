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
        assert_redirected_to controller: 'two_factor_authentication', action: 'show'
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
        assert_redirected_to controller: 'two_factor_authentication', action: 'show'
      end
    end

    describe 'user' do
      it 'uses current_user if current_user exists' do
        ApplicationController.stubs(:current_user).returns(user)

        get show_two_factor_authentication_path

        assert_response :success
      end

      it 'looks in the session for user_id or unauthenticated_id, when there is no current_user' do
      end
    end

    describe 'it handles namespaced user models' do
      let(:user) { Namespace::User.create(username: 'user@email.com', password: 'password', phone: '12341234') }

      before do
        TwoFactorCookies.configure do |config|
          # otp generation and verification
          config.otp_generation_secret_key = 'AXFGXT27ZK4PFSPWOD5COTZ6D56SPNYH'

          # controllers
          config.two_factor_authentication_success_route = :root_path
          config.toggle_two_factor_success_route = :edit_user_path
          config.confirm_phone_number_success_route = :edit_user_path

          # cookie expiry
          config.two_factor_authentication_expiry = 30.days.from_now
          config.otp_expiry = 30.minutes.from_now

          # text message sending
          config.twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
          config.twilio_phone_number = ENV['TWILIO_PHONE_NUMBER']
          config.twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']

          # user model
          config.user_model_namespace = 'Namespace'
          config.user_model_name = :user
          config.phone_number_field_name = :phone
          config.username_field_name = :username
        end
      end

      after do
        TwoFactorCookies.configure do |config|
          # otp generation and verification
          config.otp_generation_secret_key = 'AXFGXT27ZK4PFSPWOD5COTZ6D56SPNYH'

          # controllers
          config.two_factor_authentication_success_route = :root_path
          config.toggle_two_factor_success_route = :edit_user_path
          config.confirm_phone_number_success_route = :edit_user_path

          # cookie expiry
          config.two_factor_authentication_expiry = 30.days.from_now
          config.otp_expiry = 30.minutes.from_now

          # text message sending
          config.twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
          config.twilio_phone_number = ENV['TWILIO_PHONE_NUMBER']
          config.twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']

          # user model
          config.user_model_namespace = nil
          config.user_model_name = :user
          config.phone_number_field_name = :phone
          config.username_field_name = :username
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
