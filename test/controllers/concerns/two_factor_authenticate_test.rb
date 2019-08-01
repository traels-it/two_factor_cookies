# require 'test_helper'

# class TwoFactorAuthenticateTest < ActiveSupport::TestCase
#   include TwoFactorAuthenticate

#   describe 'additional_authentication_values_approved?' do
#     after do
#       TwoFactorCookies.configuration.additional_authentication_values = {}
#     end

#     it 'is true if there are no additional_authentication_values' do
#       def cookies
#         stub(encrypted: { mfa: { user_name: 'user', approved: true }.to_json })
#       end

#       assert additional_authentication_values_approved?
#     end

#     it 'is true if the method in the configuration returns a value equal to the value in the cookie' do
#       TwoFactorCookies.configuration.additional_authentication_values = { additional_value_one: 'hello_method', additional_value_two: 'hello_again_method' }

#       def cookies
#         stub(encrypted: { mfa: { user_name: 'user', approved: true, additional_value_one: 'hello', additional_value_two: 'hello_again' }.to_json })
#       end

#       def hello_method
#         'hello'
#       end

#       def hello_again_method
#         'hello_again'
#       end

#       assert additional_authentication_values_approved?
#     end

#     it 'is false if just one value has a mismatch' do
#       TwoFactorCookies.configuration.additional_authentication_values = { additional_value_one: 'hello_method', additional_value_two: 'hello_again_method' }

#       def cookies
#         stub(encrypted: { mfa: { user_name: 'user', approved: true, additional_value_one: 'hello', additional_value_two: 'hello_again' }.to_json })
#       end

#       def hello_method
#         'hello'
#       end

#       def hello_again_method
#         'not_hello'
#       end

#       assert_not additional_authentication_values_approved?
#     end
#   end
# end
