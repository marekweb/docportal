class MigrateEntityAssociations < ActiveRecord::Migration
  def up
    User.all.each do |u|
      e = Entity.find_by(id: u.entity_id)
      if e.present?
        u.entities << Entity.find(u.entity_id)
        u.save
      end
    end
  end
end
