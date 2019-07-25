
class ToggleTwoFactorController < TwoFactorAuthenticationController
  def update
    if TwoFactorAuthentication::OneTimePasswordGenerator.verify_code(
      confirm_phone_number_params[:one_time_password],
      parsed_mfa_cookie[:seed]
    )
      current_user.confirmed_phone_number.update(confirmed_phone_number: true)

      set_authenticated_cookie
      flash[:notice] = I18n.t('two_factor_authentication.confirm_phone_number.flash.confirmed')
    else
      flash[:alert] = I18n.t('two_factor_authentication.confirm_phone_number.flash.wrong_one_time_password')
    end

    redirect_to edit_customer_path(current_user.id.to_i)
  end

  def toggle_two_factor
    current_user.confirmed_phone_number.update(toggle_two_factor_params)
    if toggle_two_factor_params[:two_factor_enabled] == '1'
      # TODO: Validate the phone number before attempting to send text
      set_authenticated_cookie
    else
      current_user.confirmed_phone_number.update(confirmed_phone_number: false)
    end

    redirect_to edit_customer_path(current_user.id.to_i)
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
      params.require(:customer).permit(:two_factor_enabled)
    end
end
