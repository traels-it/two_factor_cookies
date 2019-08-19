TwoFactorCookies.const_set('ToggleTwoFactorController',
  Class.new('TwoFactorCookies::TwoFactorAuthenticationController'.constantize) do
    include TwoFactorCookies.configuration.toggle_two_factor_after_action.constantize if TwoFactorCookies.configuration.toggle_two_factor_after_action

    def update
      if TwoFactorCookies::OneTimePasswordGenerator.verify_code(
        confirm_phone_number_params[:one_time_password],
        parsed_mfa_cookie[:seed]
      )
        current_user.confirm_phone_number!

        set_authenticated_cookie
        flash[:notice] = I18n.t('two_factor_cookies.confirm_phone_number.flash.confirmed')
      else
        flash[:alert] = I18n.t('two_factor_cookies.confirm_phone_number.flash.wrong_one_time_password')
      end

      redirect_to eval(TwoFactorCookies.configuration.engine_name).public_send(
        TwoFactorCookies.configuration.confirm_phone_number_success_route,
        current_user.to_param)
    end

    def toggle_two_factor
      if toggle_two_factor_params[:enabled_two_factor] == '1'
        current_user.enable_two_factor!
        current_user.update(update_params) if TwoFactorCookies.configuration.update_params
        set_authenticated_cookie
        log(I18n.t('two_factor_cookies.logger.toggle_2fa_on', id: current_user.id)) if TwoFactorCookies.configuration.toggle_two_factor_after_action
      else
        current_user.disable_two_factor!
        current_user.disaffirm_phone_number!
        log(I18n.t('two_factor_cookies.logger.toggle_2fa_off', id: current_user.id)) if TwoFactorCookies.configuration.toggle_two_factor_after_action
      end

      redirect_to eval(TwoFactorCookies.configuration.engine_name).public_send(
        TwoFactorCookies.configuration.toggle_two_factor_success_route, current_user.to_param
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
        params.require(TwoFactorCookies.configuration.user_model_name).permit(
          :enabled_two_factor
        )
      end

      def update_params
        params.require(TwoFactorCookies.configuration.user_model_name).permit(
          TwoFactorCookies.configuration.update_params
        )
      end
  end
)
