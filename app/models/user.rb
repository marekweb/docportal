class User < ActiveRecord::Base

  has_secure_password
  
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  
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
  
  def advisor?
    fund_memberships.any? { |fm| fm.role == "advisor" }
  end
  
  def mark_sign_in!
    self.last_sign_in_at = current_sign_in_at
    self.current_sign_in_at = DateTime.now
    sign_in_count ||= 0
    sign_in_count += 1
    save
  end
  
  def generate_activation_token
    self.activation_token = Devise.friendly_token.first(16) 
  end
  
  def login_status_string
    if current_sign_in_at.present?
      return "Last login " + current_sign_in_at.in_time_zone.strftime('%Y-%m-%d')
    else
      if activation_sent_at.present?
        if activation_token.present?
          return "Activation email sent " + activation_sent_at.in_time_zone.strftime('%Y-%m-%d')
        else
          return "Activated but not logged in"
        end
      else
        return "Activation email not sent"
      end
    end
    
  end
  
  def error_sentence
    if errors.any?
      errors.full_messages.to_sentence.capitalize + '.'
    else
      ""
    end
  end
  
  def visible_documents
    if admin?
      DocumentFilter.find_documents_visible_to_admin
    else
      DocumentFilter.find_documents_visible_to_user(self)
    end
  end
  
end
