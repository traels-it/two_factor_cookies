module TwoFactorAuthenticate
  extend ActiveSupport::Concern

  included do
    before_action :two_factor_authenticate!
  end

  private

    def two_factor_authenticate!
      return unless current_user
      return unless current_user.enabled_two_factor? && current_user.confirmed_phone_number?
      return if two_factor_approved?

      redirect_to two_factor_cookies.show_two_factor_authentication_path
    end

    def two_factor_approved?
      return false if cookies.encrypted[:mfa].nil?
      return false if parsed_cookies[:user_name] != current_user.public_send(TwoFactorCookies.configuration.username_field_name)
      return false unless additional_authentication_values_approved?

      parsed_cookies[:approved]
    end

    def additional_authentication_values_approved?
      TwoFactorCookies.configuration.additional_authentication_values.each_pair do |key, value|
        return false if parsed_cookies[key] != eval(value)
      end

      true
    end

    def parsed_cookies
      JSON.parse(cookies.encrypted[:mfa]).symbolize_keys
    end
end
