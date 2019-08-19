module Log
  extend ActiveSupport::Concern

  def log(message)
    Rails.logger.info message
  end
end
