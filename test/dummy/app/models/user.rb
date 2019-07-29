class User < ApplicationRecord
  def self.logon(_username, _password)
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

  def enable_two_factor!
    self.enabled_two_factor = true
    save
  end

  def disable_two_factor!
    self.enabled_two_factor = false
    save
  end
end
