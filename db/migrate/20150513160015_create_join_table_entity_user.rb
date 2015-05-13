class CreateJoinTableEntityUser < ActiveRecord::Migration
  def change
    create_join_table :entities, :users do |t|
      # t.index [:entity_id, :user_id]
      # t.index [:user_id, :entity_id]
    end
  end
end
