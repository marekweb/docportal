namespace :notifications do

  desc "Send daily notifications email to all users"
  task send: :environment do
    
    recent_documents = BoxDocument.where('synced_at > ?', 24.hours.ago)
    
    puts "Candidate documents for everyone: #{recent_documents.count}"

    if recent_documents.count == 0
      puts "No recent documents at all; aborting notification."
      next
    end
    
    User.all.each do |user|
      send_notification_email(user, recent_documents)
    end
    
  end
  
  def send_notification_email(user, recent_documents) 

    notifiable_documents = user.visible_documents(recent_documents)
    
    if notifiable_documents.count > 0
      puts "(TEST) Sending document notification to #{user.display_name}"
      # MandrillMailer.send_notification_email(user)
    end
    
  end

end