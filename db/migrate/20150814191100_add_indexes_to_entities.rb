class AddIndexesToEntities < ActiveRecord::Migration
  def change
    add_index :entities, :id
    add_index :entities, :name
    
    add_index :entities_users, :entity_id
    add_index :entities_users, :user_id
    
    add_index :box_documents, :fund
    add_index :box_documents, :visibility_tag
    add_index :box_documents, :fund_tag
    add_index :box_documents, :entity_name
    
  end
end
