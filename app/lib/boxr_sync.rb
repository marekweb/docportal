class BoxrSync
  
  def initialize
    box_access = BoxAccess.first
    
    # The following call fetches following ENV variables by default
    # BOX_CLIENT_ID
    # BOX_CLIENT_SECRET
    
    @client = Boxr::Client.new(box_access.token, refresh_token: box_access.refresh_token) do |access_token, refresh_token|
      # This block gets executed when the token gets refreshed
      puts "BOXR refreshed access token and refresh token."
      box_access = BoxAccess.first
      box_access.token = access_token
      box_access.refresh_token = refresh_token
      box_access.save
    end

  end
  
  def current_user
      @client.current_user
  end

  def all_files_recursive_from_path(path)
    folder = @client.folder_from_path(path)
    all_files_recursive(folder)
  end

  # Recursively lists all the files in a Box folder
  # Returns a list of RubyBox file objects
  def all_files_recursive(folder)
    files = []
    
    attempts = 3
    begin
      all_items = @client.folder_items(folder, fields: [:etag, :sha1, :name, :type, :path_collection, :created_at, :created_by, :download_url, :updated_at])
    rescue => error
      attempts -= 1
      if attempts > 0
        puts "BOXR an error happened, retrying... #{error}"
        puts "BOXR retry attempts remaining #{attempts}"
        retry
      end
      raise
    end
    
    all_items.each do |i|

      if i.type == "file"
        files << i
      elsif i.type == "folder"
        puts "BOXR entering folder: #{i.name}"
        
        # Rate limiting
        # Box API docs don't say what the rate limit is so this is
        # a guess
        # sleep 0.05

        # Recurse
        recursive_files = all_files_recursive(i.id)

        # Collect the files into the overall list
        files += recursive_files

      end
    end

    return files

  end
  
  def client
    @client
  end

end

