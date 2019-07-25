class User < ApplicationRecord
  def self.logon(username, password)
    true
  end

  def disaffirm_phone_number!
    self.confirmed_phone_number = false
    save
  end

  def confirm_phone_number!
    self.confirmed_phone_number = true
    save
  end
end
