module TwoFactorCookies
  class ToggleTwoFactorController < TwoFactorCookies::TwoFactorAuthenticationController
    def update
      if TwoFactorCookies::OneTimePasswordGenerator.verify_code(
        confirm_phone_number_params[:one_time_password],
        parsed_mfa_cookie[:seed]
      )
        current_user.confirm_phone_number!

        set_authenticated_cookie
        flash[:notice] = I18n.t('two_factor_authentication.confirm_phone_number.flash.confirmed')
      else
        flash[:alert] = I18n.t('two_factor_authentication.confirm_phone_number.flash.wrong_one_time_password')
      end

      redirect_to main_app.public_send(
        TwoFactorCookies.configuration.confirm_phone_number_success_route,
        current_user.id.to_i)
    end

    def toggle_two_factor
      if toggle_two_factor_params[:enabled_two_factor] == '1'
        # TODO: Validate the phone number before attempting to send text
        current_user.enable_two_factor!
        set_authenticated_cookie
      else
        current_user.disable_two_factor!
        current_user.disaffirm_phone_number!
      end

      redirect_to main_app.public_send(
        TwoFactorCookies.configuration.toggle_two_factor_success_route, current_user.id.to_i
      )
    end

    def resend_code
      send_otp

      head :ok
    end

    private

      def confirm_phone_number_params
        params.require(:confirm_phone_number).permit(:one_time_password)
      end

      def toggle_two_factor_params
        params.require(:user).permit(:enabled_two_factor)
      end

      def user
        current_user
      end
  end
end
