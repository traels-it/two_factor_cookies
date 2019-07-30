class CreateNamespaceUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :namespace_users do |t|
      t.string :phone
      t.string :username
      t.string :password
      t.boolean :confirmed_phone_number
      t.boolean :enabled_two_factor

      t.timestamps
    end
  end
end
