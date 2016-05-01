require 'sendgrid-ruby'

class SendgridMailer

  def self.template_id_for_account_creation
    "3c8d35a7-72a4-4d3b-ad73-3358249b178e"
  end

  def self.template_id_for_password_reset
    "a1c145cf-41f1-4696-bdb8-65484115c385"
  end

  def self.send_activation(user)

    merge_vars = {
      ":fname" => user.first_name,
      ":href" => 'https://' + ENV['HOSTNAME'] + '/activate_password?token=' + user.activation_token,
      ":email" => user.email,
    }

    self.send_template template_id_for_account_creation, user.display_name, user.email, merge_vars

    user.activation_sent_at = DateTime.now
    user.save

  end

  def self.send_password_reset(user)

    merge_vars = {
      ":fname" => user.first_name,
      ":href" => 'https://' + ENV['HOSTNAME'] + '/select_password?token=' + user.reset_password_token,
      ":email" => user.email
    }

    self.send_template template_id_for_password_reset, user.display_name, user.email, merge_vars
    user.reset_password_sent_at = DateTime.now
    user.save

  end

  def self.send_template(template_name, recipient_name, recipient_email, merge_hash, test_mode=false)

    merge_vars = Hash[merge_hash.map{|key, value| [key, [value]] } ]

    smtpapi_values = {
      "sub" => merge_vars,
      "filters" => {
        "templates" => {
          "settings" => {
            "enable" => 1,
            "template_id" => template_name
          }
        }
      }
    }


    begin

      mail = SendGrid::Mail.new do |m|
        m.to_name = recipient_name
        m.to = recipient_email
        m.from_name = 'Real Ventures'
        m.from = 'admin@realventures.com'
        m.subject = 'x1'
        m.text = 'x2' # This is required, but blank because a template is used for the actual body.
        m.smtpapi = smtpapi_values
      end

      unless test_mode
        client = sendgrid_client_instance
        res = client.send(mail)

        puts res.code
        puts res.body

      else
        puts "SendGrid email not sent; test mode is active."
      end


    end
  end

  def self.send_new_document_notification(user)

    merge_vars = {
      "fname" => user.first_name
    }

    # NOTE: the last parameter is a boolean to set test mode
    self.send_template "lp-portal-new-document-notification", user.display_name, user.email, merge_vars, true
  end

  def self.sendgrid_client_instance
    client = SendGrid::Client.new do |c|
      c.api_key = ENV['SENDGRID_API_KEY']
    end
  end

end