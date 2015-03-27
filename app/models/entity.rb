class Entity < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :fund_memberships

  def role_for(fund)
    fm = FundMembership.find_by(entity_id: id, fund: fund)
    return fm.try(:role)
  end

  def self.normalize_name(name)
    # Get the entity name as it appears in the Entity table,
    # given the lowercase tentative name that is stored in a BoxDocument
    Entity.find_by(['lower(name) = ?', name]).try(:name) || name.capitalize
  end
end
