class AddActivationTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :activation_token, :string
    rename_column :users, :token, :reset_password_token
  end
end
