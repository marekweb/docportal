class NewFileNotifier
  
  def self.new_files_for_user(user)
    
    return BoxDocument.none if user.current_sign_in_at.nil?
    
  end
  
end