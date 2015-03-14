class BoxSyncClient

  def initialize(box_client)
    @box_client = box_client
  end
  
  # List all files in a folder -- but not the folders.
  def all_files(folder_id=0)
    @box_client.folder_by_id(folder_id).files
  end
  
  def all_folders(folder_id=0)
    @box_client.folder_by_id(folder_id).folders
  end
  
  def all_items(folder_id=0)
    @box_client.folder_by_id(folder_id).items(100, 0, [:etag, :sha1, :name, :type, :path_collection, :created_at, :created_by, :download_url])
  end
  
  def find_root_folder_by_name(name, folder_id=0)
    root_subfolders = all_folders(folder_id)
    target_subfolder = root_subfolders.find { |f| f.name == name }
    return target_subfolder && target_subfolder.id
  end
  
  def all_files_recursive_by_root_folder_name(name)
    folder_id = find_root_folder_by_name(name)
    all_files_recursive(folder_id)
  end

  # Recursively lists all the files in a Box folder
  # Returns a list of RubyBox file objects
  def all_files_recursive(folder_id=0)
    files = []
    
    all_items(folder_id).each do |i|
      
      puts "#{i.type} #{i.id} #{i.name}"
      
      if i.type == "file"
        files << i
      elsif i.type == "folder"

        # Rate limiting
        # Box API docs don't say what the rate limit is so this is
        # a guess
        #sleep 0.1

        # Recurse
        recursive_files = all_files_recursive(i.id)

        # Collect the files into the overall list
        files += recursive_files

      end
    end
    
    return files
    
  end
  
  
end
