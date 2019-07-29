require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include TwoFactorCookies::Engine.routes.url_helpers

  let(:user) { User.create(username: 'username', password: 'password', phone: '+4512341234', confirmed_phone_number: false, enabled_two_factor: false) }

  describe '2fa not approved' do
    before do
      TwoFactorCookies::TextMessage.stubs(:send)
      user.update(confirmed_phone_number: true, enabled_two_factor: true)
    end

    it 'redirects to two_factor_authentication controller' do
      post login_url, params: { username: user.username, password: user.password }

      assert_redirected_to two_factor_cookies.show_two_factor_authentication_path
    end
  end

  describe '2fa enabled, but number is not confirmed' do
    it 'does not do 2fa' do
      user.update(enabled_two_factor: true)

      post login_url, params: { username: user.username, password: user.password }

      assert_redirected_to root_url
    end
  end
end
