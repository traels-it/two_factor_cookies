module TwoFactorAuthenticate
  extend ActiveSupport::Concern

  private

    def two_factor_authenticate?(user)
      return false unless user
      return false unless user.enabled_two_factor? && user.confirmed_phone_number?
      return false if two_factor_approved?(user)

      true
    end

    def two_factor_approved?(user)
      return false if cookies.encrypted[:mfa].nil?

      parsed_cookies = JSON.parse(cookies.encrypted[:mfa]).symbolize_keys
      return false if parsed_cookies[:user_name] != user.username

      parsed_cookies[:approved]
    end
end
