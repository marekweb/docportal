class BoxViewClient
  
  def self.logger
    @@logger ||= Logger.new(STDOUT)
  end
  
  def self.box_view_conn
    conn = Faraday.new
    conn.headers['Content-Type'] = 'application/json'
    conn.headers['Authorization'] = "Token #{box_view_api_key}"
    conn
  end
  
  def self.box_view_api_key
    ENV["BOX_VIEW_API_KEY"]
  end
  
  # returns (session id, DateTime expiration)
  def self.box_view_create_session(document_id)
    document_id = document_id
    conn = self.box_view_conn
    post_data = {
      document_id: document_id,
      
      # Duration (minutes) until the session expires
      # This is how long the box view api link (that uses the session id) will remain valid
      duration: 10,
      
      # This flag allows the file to be downloaded using the download link
      is_downloadable: true
    }
    response = conn.post("https://view-api.box.com/1/sessions", post_data.to_json)

    # response status 202: not ready yet
    # response status 400: the file is not convertable
    self.logger.debug "box_view_create_session: response #{response.status}"
    self.logger.debug response.to_json
    if response.status == 201
        response_fields = JSON.parse(response.body)
        logger.debug "EXPIRES_AT #{response_fields['expires_at']}"
        return response_fields["id"], DateTime.parse(response_fields['expires_at'])
    else
        return nil, nil
    end

  end
  
  def self.box_get_view_session(box_document)
    
    box_view_id = box_document.box_view_id
    
    self.logger.debug "Looking up box_view_id = #{box_view_id}"

    if box_document.box_session_id.present? && box_document.box_session_expiration.present? && box_document.box_session_expiration > 1.minute.from_now
      self.logger.debug "Already has a recent session"
      document_session_id = box_document.box_session_id
    else
      self.logger.debug "Creating a new session"
      document_session_id, document_session_expiration = self.box_view_create_session(box_view_id)
      if document_session_id.present?
        box_document.box_session_id = document_session_id
        box_document.box_session_expiration = document_session_expiration
        box_document.save
      end
    end

    self.logger.debug "Session id = #{document_session_id}"
    document_session_id
  end
  
  def self.make_request(url, body)
    conn = self.box_view_conn
    conn.post(url, body.to_json)
  end

  def self.convert_document(download_url, retrying=false)

    response = make_request("https://view-api.box.com/1/documents", {url: download_url, name: ""})
  
    fields = JSON.parse(response.body)
    
    id = fields["id"]
  
    if id.nil?
      self.logger.debug("Convert document did not succeed")
      self.logger.debug("Response status=#{response.status}")
      self.logger.debug(response.body)
      
      # Response 429 = Rate limitation, wait 2 seconds and retry.
      if response.status == 429 && !retrying
        delay = response.headers['Retry-After'].to_i || 2.0
        sleep delay
        return self.convert_document(download_url, true)
      end
    end

    id
  end  
  
end
