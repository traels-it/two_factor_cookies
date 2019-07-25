class AddConfirmedPhoneNumberAndEnableTwoFactorToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :confirmed_phone_number, :boolean
    add_column :users, :enabled_two_factor, :boolean
  end
end
