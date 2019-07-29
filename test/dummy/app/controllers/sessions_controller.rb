class SessionsController < ApplicationController
  def new
    if (user = User.logon(params[:username], params[:password]))
      if two_factor_authenticate?(user)
        session[:unauthenticated_user_id] = user.id
        redirect_to two_factor_cookies.show_two_factor_authentication_path
      else
        session[:user_id] = user.to_param
        redirect_to root_url, notice: t('session.logged_in')
      end
    else
      session[:user_id] = nil
      redirect_to root_url, notice: t('session.invalid_user_or_pass')
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: t('session.logged_out')
  end

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
      return false if parsed_cookies[:user_name] != user.login_mail

      parsed_cookies[:approved]
    end
end
