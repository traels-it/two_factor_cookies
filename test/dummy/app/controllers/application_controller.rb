class ApplicationController < ActionController::Base
  include TwoFactorAuthenticate

  def current_user
    @current_user ||= User.first
  end

  # example helper for additional authentication values
  def current_company
    OpenStruct.new(customer_no: 100_001)
  end

  def log(message)
    Rails.logger.info message
  end
end
