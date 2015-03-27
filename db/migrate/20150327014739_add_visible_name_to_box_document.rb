class AddVisibleNameToBoxDocument < ActiveRecord::Migration
  def change
    add_column :box_documents, :visible_name, :boolean
  end
end
