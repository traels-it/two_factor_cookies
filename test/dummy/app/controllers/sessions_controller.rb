class SessionsController < ApplicationController
  def new
    if user = User.logon(params['user'], params['pass'])
      session[:user_id] = user.to_param
      redirect_to root_url, notice: t('session.logged_in')
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
