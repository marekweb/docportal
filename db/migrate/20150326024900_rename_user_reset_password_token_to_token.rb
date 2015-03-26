class RenameUserResetPasswordTokenToToken < ActiveRecord::Migration
  def change
    rename_column :users, :reset_password_token, :token
    add_column :users, :activation_sent_at, :datetime
  end
end
