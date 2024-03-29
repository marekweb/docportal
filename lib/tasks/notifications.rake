namespace :notifications do

  desc "Send daily notifications email to all users"
  task send: :environment do
    
    recent_documents = BoxDocument.where('synced_at > ?', 24.hours.ago)
    
    puts "Candidate documents for everyone: #{recent_documents.count}"

    if recent_documents.count == 0
      puts "No recent documents at all; aborting notification."
      next
    end
    
    box_access = BoxAccess.first
    if !box_access.notifications_enabled
      puts "Notifications are disabled; aborting notification."
      next
    end
    
    User.all.each do |user|
      send_notification_email(user, recent_documents)
    end
    
  end
  
  def send_notification_email(user, recent_documents) 

    notifiable_documents = user.visible_documents(recent_documents)
    
    if notifiable_documents.count > 0
      puts "(NOTIFICATION) Sending document notification to #{user.display_name}"
      SendgridMailer.send_new_document_notification(user)
    end
    
  end

end