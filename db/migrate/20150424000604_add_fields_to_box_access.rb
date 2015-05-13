class AddFieldsToBoxAccess < ActiveRecord::Migration
  def change
    add_column :box_accesses, :general_message, :string
    add_column :box_accesses, :general_message_enabled, :boolean
  end
end
