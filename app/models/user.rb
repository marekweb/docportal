class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  
  has_secure_password
  
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  belongs_to :entity
  has_many :fund_memberships, through: :entity

  def initials
    (first_name[0] + last_name[0]).upcase
  end
  
  def display_name
    "#{first_name} #{last_name}"
  end
  
  def admin?
    return id == 1
  end
  
end