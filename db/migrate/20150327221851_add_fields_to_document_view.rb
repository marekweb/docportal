class AddFieldsToDocumentView < ActiveRecord::Migration
  def change
    add_column :document_views, :last_opened_at, :datetime
    add_column :document_views, :last_downloaded_at, :datetime
    rename_column :document_views, :opened_at, :first_opened_at
    rename_column :document_views, :downloaded_at, :first_downloaded_at
  end
end
