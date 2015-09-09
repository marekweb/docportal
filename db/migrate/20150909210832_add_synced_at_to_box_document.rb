class AddSyncedAtToBoxDocument < ActiveRecord::Migration
  def change
    add_column :box_documents, :synced_at, :datetime
  end
end
