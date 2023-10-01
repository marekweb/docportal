require 'mandrill'

class MandrillMailer

  def self.sender_name
    ENV['EMAIL_SENDER_NAME']
  end

  def self.sender_email
    ENV['EMAIL_SENDER_EMAIL']
  end
  
  def self.send_activation(user)
    
    merge_vars = {
      "fname" => user.first_name,
      "href" => 'https://' + ENV['HOSTNAME'] + '/activate_password?token=' + user.activation_token,
      "email" => user.email,
    }
    
    self.send_template "lp-portal-account-creation", user.display_name, user.email, merge_vars
    
    user.activation_sent_at = DateTime.now
    user.save
    
  end
  
  def self.send_password_reset(user)
    
    merge_vars = {
      "fname" => user.first_name,
      "href" => 'https://' + ENV['HOSTNAME'] + '/select_password?token=' + user.reset_password_token,
      "email" => user.email
    }
    
    self.send_template "lp-portal-password-reset", user.display_name, user.email, merge_vars
    user.reset_password_sent_at = DateTime.now
    user.save
    
  end
  
  def self.send_template(template_name, recipient_name, recipient_email, merge_hash, test_mode=false)
      
    merge_vars = merge_hash.map { |k, v| {"name" => k, "content" => v} }
    
    begin
      message = {
        #"subject"=>"example subject",
        "merge_language"=>"mailchimp",
        "merge"=>true,
        "global_merge_vars"=> merge_vars,
    
        "auto_text"=>true,
        "to" => [{
          "email" => recipient_email,
          "type" => "to",
          "name" => recipient_name
        }],
        "from_name"=> sender_name,
        "from_email"=> sender_email
      }
      
      instance = if test_mode
        puts "MandrillMailer in TEST MODE"
        self.mandrill_test_instance
      else
        self.mandrill_instance
      end

      result = instance.messages.send_template template_name, [], message
      
      puts "Mandrill"
      puts result
      
    end
  end
  
  def self.send_new_document_notification(user)
    
    merge_vars = {
      "fname" => user.first_name
    }
    
    self.send_template "lp-portal-new-document-notification", user.display_name, user.email, merge_vars, true
  end
  
  def self.mandrill_instance
    Mandrill::API.new ENV['MANDRILL_API_KEY']
  end
  
  def self.mandrill_test_instance
    Mandrill::API.new ENV['MANDRILL_API_TEST_KEY']
  end
  
end
