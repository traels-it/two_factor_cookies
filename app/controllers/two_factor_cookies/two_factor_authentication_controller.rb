TwoFactorCookies.const_set('TwoFactorAuthenticationController',
  Class.new(TwoFactorCookies.configuration.two_factor_authentication_controller_parent.constantize) do
    layout TwoFactorCookies.configuration.layout_path if TwoFactorCookies.configuration.layout_path

    skip_before_action :two_factor_authenticate! if TwoFactorCookies.configuration.skip_before_action # TODO: skal navnet også være configurable? Eller er det altid den samme action?

    def show
      send_otp unless otp_already_sent?

      render :show, locals: { user: user }
    end

    def update
      if otp_verified?
        set_authenticated_cookie
        authenticate_user!
        redirect_to mus.public_send(TwoFactorCookies.configuration.two_factor_authentication_success_route) # TODO: I mus skal main_app.public_send være mus.public_send. Hvordan gør jeg det configurable? .global_variable_set?
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
          user: user
        )

        set_seed_cookie(generated[:seed])
      end

      def set_authenticated_cookie
        cookies.delete(:mfa)
        cookies.encrypted[:mfa] = {
          value: JSON.generate(
            standard_values.merge(additional_authentication_values)
          ),
          expires: TwoFactorCookies.configuration.two_factor_authentication_expiry
        }
      end

      def set_seed_cookie(seed)
        cookies.delete(:mfa)
        cookies.encrypted[:mfa] = {
          value: JSON.generate(seed: seed, user_name: user.public_send(TwoFactorCookies.configuration.username_field_name)),
          expires: TwoFactorCookies.configuration.otp_expiry
        }
      end

      def parsed_mfa_cookie
        JSON.parse(cookies.encrypted[:mfa]).symbolize_keys
      end

      def user
        return current_user if current_user.present?

        user_id = session[:user_id] || session[:unauthenticated_user_id]
        @user ||= user_model.find(user_id)
      end

      def authenticate_user!
        session[:user_id] = user.to_param
        session.delete(:unauthenticated_user_id)
      end

      def user_model
        user_model = ''
        user_model += "#{TwoFactorCookies.configuration.user_model_namespace}::" if TwoFactorCookies.configuration.user_model_namespace
        user_model += TwoFactorCookies.configuration.user_model_name.to_s.capitalize
        user_model.constantize
      end

      def standard_values
        {
          approved: true,
          user_name: user.public_send(TwoFactorCookies.configuration.username_field_name)
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
