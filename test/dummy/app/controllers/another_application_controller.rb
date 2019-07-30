class AnotherApplicationController < ActionController::Base
  def current_user
    @current_user ||= User.find(session[:user_id]) unless session[:user_id].nil?
  end
end
