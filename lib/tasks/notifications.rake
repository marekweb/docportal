namespace :notifications do

  desc "Send daily notifications email to all users"
  task send: :environment do
    users = User.all
    
    users.each do |user|
      send_notification_email(user)
    end
    
  end
  
  def send_notification_email(user)
    date = Date.today
    
    files = user.visible_documents.where(upload_date: date)
    
  end

end