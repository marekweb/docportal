require 'mandrill'

class MandrillMailer
  
  def self.send_activation user
    
    merge_vars = {
      "fname" => user.first_name,
      "href" => 'https://' + ENV['HOSTNAME'] + '/select_password?q=' + user.reset_password_token,
      "email" => user.email,
      "logo_url" => 'https://' + ENV['HOSTNAME'] + '/assets/real-ventures.png'
    }
    
    self.send_template "lp-portal-account-creation", user.display_name, user.email, merge_vars
  end
  
  def self.send_template(template_name, recipient_name, recipient_email, merge_hash)
      
    merge_vars = merge_hash.map { |k, v| {"name" => k, "content" => v} }
    
    real_logo_image = {
      "type"=>"image/png",
      "content"=>"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",
      "name"=>"reallogo"
    }
    
    begin
      message = {
        "subject"=>"example subject",
        "merge_language"=>"mailchimp",
        "merge"=>true,
        "global_merge_vars"=> merge_vars,
        "images" => [real_logo_image],
    
        #"headers"=>{"Reply-To"=>"admin@realventures.com"},
        "auto_text"=>true,
        "to" => [{
          "email" => recipient_email,
          "type" => "to",
          "name" => recipient_name
        }],
        "from_name"=>"Real Ventures",
        "from_email"=>"admin@realventures.com"
      }

      result = self.mandrill_instance.messages.send_template template_name, [], message
      
      puts "Mandrill"
      puts result
      
    end
  end
  
  def self.mandrill_instance
    Mandrill::API.new ENV['MANDRILL_API_KEY']
  end
  
end