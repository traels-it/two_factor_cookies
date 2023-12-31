class SessionsController < ApplicationController

  def new
    if (user = User.logon(params[:username], params[:password]))
      if two_factor_authenticate!
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
end
