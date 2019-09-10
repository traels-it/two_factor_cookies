TwoFactorCookies.const_set('TwoFactorAuthenticationController',
  Class.new(TwoFactorCookies.configuration.two_factor_authentication_controller_parent.constantize) do
    layout TwoFactorCookies.configuration.layout_path if TwoFactorCookies.configuration.layout_path

    skip_before_action :two_factor_authenticate!

    def show
      send_otp unless otp_already_sent?

      render :show, locals: { user: current_user }
    end

    def update
      if otp_verified?
        set_authenticated_cookie
        redirect_to public_send(TwoFactorCookies.configuration.two_factor_authentication_success_route)
      else
        flash[:alert] = I18n.t('two_factor_cookies.errors.wrong_one_time_password')
        redirect_to two_factor_cookies.show_two_factor_authentication_path
      end
    end

    def resend_code
      send_otp

      redirect_to two_factor_cookies.show_two_factor_authentication_path
    end

    private

      def otp_already_sent?
        cookies.encrypted[:mfa].present? && parsed_mfa_cookie[:seed].present?
      end

      def otp_verified?
        return false unless cookies[:mfa].present?

        TwoFactorCookies::OneTimePasswordGenerator.verify_code(
          two_factor_authentication_params[:one_time_password],
          parsed_mfa_cookie[:seed]
        )
      end

      def two_factor_authentication_params
        params.require(:two_factor_authentication).permit(:one_time_password)
      end

      def send_otp
        generated = TwoFactorCookies::OneTimePasswordGenerator.generate_code
        TwoFactorCookies::TextMessage.send(
          code: generated[:code],
          user: current_user
        )

        set_seed_cookie(generated[:seed])
      end

      def set_authenticated_cookie
        cookies.delete(:mfa)
        cookies.encrypted[:mfa] = {
          value: JSON.generate(
            standard_values.merge(additional_authentication_values)
          ),
          expires: Time.zone.now + TwoFactorCookies.configuration.two_factor_authentication_expiry
        }
      end

      def set_seed_cookie(seed)
        cookies.delete(:mfa)
        cookies.encrypted[:mfa] = {
          value: JSON.generate(seed: seed, user_name: current_user.public_send(TwoFactorCookies.configuration.username_field_name)),
          expires: Time.zone.now + TwoFactorCookies.configuration.otp_expiry
        }
      end

      def parsed_mfa_cookie
        JSON.parse(cookies.encrypted[:mfa]).symbolize_keys
      end

      def standard_values
        {
          approved: true,
          user_name: current_user.public_send(TwoFactorCookies.configuration.username_field_name)
        }
      end

      def additional_authentication_values
        return {} unless TwoFactorCookies.configuration.additional_authentication_values

        # TODO: Is there a better way, than to use eval?
        additional_values = {}
        TwoFactorCookies.configuration.additional_authentication_values.each_pair do |key, value|
          additional_values.store(key, eval(value))
        end
        additional_values
      end
  end
)
