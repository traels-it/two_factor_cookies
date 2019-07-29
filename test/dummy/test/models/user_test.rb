require 'test_helper'

class UserTest < ActiveSupport::TestCase
  let(:user) { User.create(username: 'username', password: 'password', phone: '+4512341234', confirmed_phone_number: false, enabled_two_factor: false) }

  describe 'logon' do
    it 'returns nil if username or password is not truthy' do
      assert_not User.logon('user', '')
      assert_not User.logon(nil, 'password')
    end

    it 'finds and returns the user object matching username and password' do
      user

      assert_equal user, User.logon('username', 'password')
    end
  end

  describe 'confirm_phone_number!' do
    it 'sets confirmed_phone_number to true' do
      user.confirm_phone_number!
      user.reload

      assert user.confirmed_phone_number?
    end
  end

  describe 'disaffirm_phone_number!' do
    it 'sets confirmed_phone_number to false' do
      user.update(confirmed_phone_number: true)
      user.disaffirm_phone_number!
      user.reload

      assert_not user.confirmed_phone_number?
    end
  end

  describe 'enable_two_factor!' do
    it 'sets enabled_two_factor to true' do
      user.enable_two_factor!
      user.reload

      assert user.enabled_two_factor?
    end
  end

  describe 'disable_two_factor!' do
    it 'sets enabled_two_factor to false' do
      user.update(enabled_two_factor: true)
      user.disable_two_factor!
      user.reload

      assert_not user.enabled_two_factor?
    end
  end
end
