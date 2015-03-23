class BoxAdapter

  def self.refresh_box_access!(box_access)
    return unless box_access.needs_refresh?
    fresh_token = refresh_token(box_access.token, box_access.refresh_token)
    box_access.update_attributes({
      token: fresh_token.token,
      refresh_token: fresh_token.refresh_token,
      last_refresh: Time.zone.now
    })
  end

  def self.create_session(access_token=nil)
    RubyBox::Session.new({
      client_id: ENV['BOX_CLIENT_ID'],
      client_secret: ENV['BOX_CLIENT_SECRET'],
      access_token: access_token
    })
  end

  def self.create_client_from_box_access(box_access)
    box_session = self.create_session(box_access.token)
    self.create_client_from_session(box_session)
  end

  def self.create_fresh_client_from_box_accuess!(box_access)
    self.refresh_box_access!(box_access)
    self.create_client_from_box_access(box_access)
  end

  def self.create_client_from_session(box_session)
     RubyBox::Client.new(box_session)
  end

  # Returns object with fields: { token, refresh_token }
  def self.refresh_token(access_token, refresh_token)
    box_session = self.create_session(access_token)
    box_session.refresh_token(refresh_token)
  end
  
  # Create a box client with the *first picked BoxAccess* which is in the database.
  def self.create_box_client!
    box_access = BoxAccess.first
    return nil if box_access.nil?
    BoxAdapter.create_fresh_client_from_box_access!(box_access) 
  end
  
  def self.create_box_sync_client
    box_client = self.create_box_client!
    BoxSyncClient.new(box_client)
  end
  
  def self.sync_folder_by_name(name)
    box_sync = self.create_box_sync_client
    box_sync.all_files_recursive_by_root_folder_name(name)
  end

  def self.sync(folder_id=0)
    box_sync = self.create_box_sync_client
    box_sync.all_files_recursive(folder_id)
  end

end