namespace :boxr do
  
  desc "Show a summary of BoxDocuments"
  task show: :environment do
    BoxDocument.all.each do |i|
      puts "#{i.display_title} (#{i.name})"
    end
  end
  
  desc "Delete all the BoxDocuments"
  task clear: :environment do
    BoxDocument.all.each do |i|
      puts "Deleting #{i.name}"
      i.destroy
    end
  end
  
  task refresh: :environment do
    puts 'TOKEN REFRESH: starting'
    box_client = BoxrSync.new
    puts box_client.current_user
    puts 'TOKEN REFRESH: done'
  end
  
  desc "Sync the system with a Box account using the Content API"
  task sync: :environment do
    
    throw "Please run with enviroment vars: foreman run rake box:sync" if ENV['BOX_CLIENT_ID'] == nil

    SyncEntry.record_sync_start
    
    tries = 0
    
    begin
      perform_sync_task
    rescue Exception => e
      SyncEntry.record_sync_failure(e)
      puts "#{e.class}: #{e.message}"
      puts e.backtrace.join(' --')
    end
    
  end
  
  def perform_sync_task

    # Box client needed for sync
    box_client = BoxrSync.new
    
    puts "SYNC: Starting sync task (perform_sync_task)"
    
    if box_client.nil?
      puts "SYNC: Box Access has not been set up. Aborting sync"
      return # Abort the rake task`
    end

    puts "SYNC: Performing Box sync on folder tree"
    root_folder_name = ENV['SYNC_FOLDER_NAME'] || 'LP Portal'
    root_folder_with_leading_slash = "/" + root_folder_name
    synced_files = box_client.all_files_recursive_from_path(root_folder_with_leading_slash)
    puts "SYNC: Done syncing file list"

    
    # Build a hash in the form: id => file
    synced_file_hash = {}
    synced_files.each do |f|
      synced_file_hash[f.id] = f
    end
    
    # Build a list of the file ids
    extant_box_ids = BoxDocument.all.pluck(:box_file_id)

    synced_box_ids = synced_files.map(&:id)
    
    created_box_ids = synced_box_ids - extant_box_ids
    destroyed_box_ids = extant_box_ids - synced_box_ids
    
    box_document_objects = []
    
    max_fund = 0 # Track the maximum fund number
    years_set = Set.new
  

    synced_files.each do |f|
      
      categorizer = Categorizer.new(f)

      category_id = categorizer.category_id
      
      year = categorizer.year
      month = categorizer.month
      quarter = categorizer.quarter
      fund = categorizer.fund || 0 # This default is needed because it must not be nil
      fund_tag = categorizer.fund_tag
      visibility_tag = categorizer.visibility_tag
      entity_name = (categorizer.entity_name if visibility_tag == "entity")
      visible_name = categorizer.visible_name?
      original_path = categorizer.full_path # The original full file path in the Box account.
      
      max_fund = [max_fund, fund].max
      years_set.add(year)

      download_url = f.download_url
      
      box_document = BoxDocument.find_or_create_by({box_file_id: f.id})
      
      box_document.assign_attributes({
        name: f.name,
        category: category_id,
        year: year,
        month: month,
        quarter: quarter,
        fund: fund,
        fund_tag: fund_tag,
        entity_name: entity_name,
        visibility_tag: visibility_tag,
        upload_date: f.created_at,
        visible_name: visible_name,
        etag: f.etag,
        original_path: original_path
      })
      
      if box_document.synced_at.nil?
        box_document.synced_at = DateTime.now
      end
      
      box_document.save
      
      if box_document.errors.any?
        puts "ERROR " + box_document.errors.full_messages.to_sentence
      end
      
    end
    
    destroyed_box_ids.each do |id|
      BoxDocument.find_by(box_file_id: id).destroy
    end
    puts "SYNC: completed all work - about to record sync end in sync entry"
    SyncEntry.record_sync_end(synced_box_ids.length, created_box_ids.length, destroyed_box_ids.length)
    puts "SYNC: DONE -- sync entry recorded, exiting rake task"
    
  end

end
