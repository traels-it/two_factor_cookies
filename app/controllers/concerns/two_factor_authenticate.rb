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

      parsed_cookies = JSON.parse(cookies.encrypted[:mfa]).symbolize_keys
      #return false if parsed_cookies[:customer_no] != current_company.customer_no # TODO: Hook up with configurable options
      return false if parsed_cookies[:user_name] != current_user.public_send(TwoFactorCookies.configuration.username_field_name)

      parsed_cookies[:approved]
    end
end
