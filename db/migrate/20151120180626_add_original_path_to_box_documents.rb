class AddOriginalPathToBoxDocuments < ActiveRecord::Migration
  def change
    add_column :box_documents, :original_path, :string
  end
end
