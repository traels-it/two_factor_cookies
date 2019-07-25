require 'test_helper'

class ToggleTwoFactorControllerTest < ActionDispatch::IntegrationTest

  let(:customer) { Customer.create(firmanavn: 'Banders band', adresse: 'Bandevej 1', postby: '1234 Bandeby', cvr: '11111111', telefon: '11111111', mail: 'dennis@globalforsikring.dk', login_mail: 'partner@partner.tld', login_password: '98989878') }

  before do
    login customer
    TwoFactorAuthentication::TextMessage.stubs(:send)
  end

  describe('#update') do
    it 'confirms a user phone number when credentials are correct' do
      TwoFactorAuthentication::OneTimePasswordGenerator.expects(:verify_code).returns(true)
      get resend_code_confirm_phone_number_path(customer_id: customer.id.to_i)
      patch confirm_phone_number_path(customer_id: customer.id.to_i), params: { confirm_phone_number: { one_time_password: '123123' } }

      assert customer.reload.confirmed_phone_number?
    end

    it 'does not confirm when supplied code is incorrect' do
      TwoFactorAuthentication::OneTimePasswordGenerator.expects(:verify_code).returns(false)
      get resend_code_confirm_phone_number_path(customer_id: customer.id.to_i)
      patch confirm_phone_number_path(customer_id: customer.id.to_i), params: { confirm_phone_number: { one_time_password: '123123' } }

      assert_not customer.reload.confirmed_phone_number?
    end
  end

  describe '#toggle_two_factor' do
    it 'updates the user if enable_two_factor is true' do
      patch toggle_two_factor_path(customer_id: customer.id.to_i), params: { customer: { two_factor_enabled: '1'}, customer_id: customer.id.to_i}
      customer.reload

      assert customer.two_factor_enabled?
    end

    it 'disables two factor if enable two factor is missing' do
      customer.confirmed_phone_number.update(confirmed_phone_number: true)

      patch toggle_two_factor_path(customer_id: customer.id.to_i), params: { customer: { two_factor_enabled: '0'}, customer_id: customer.id.to_i}
      customer.reload

      assert_not customer.two_factor_enabled?
      assert_not customer.confirmed_phone_number?
    end
  end
end
