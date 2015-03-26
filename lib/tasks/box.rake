namespace :box do
  
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
  
  desc "Sync the system with a Box account using the Content API"
  task sync: :environment do
    
    throw "Please run with enviroment vars: foreman run rake box:sync" if ENV['BOX_CLIENT_ID'] == nil

    SyncEntry.record_sync_start
    
    begin
      perform_sync_task
    rescue Exception => e
      SyncEntry.record_sync_failure(e.message)
      puts "#{e.class}: #{e.message}"
    end
    
  end
  
  def perform_sync_task

    # Box client needed for 
    box_client = BoxAdapter.create_box_client!
    
    if box_client.nil?
      puts "Box Access has not been set up. Aborting sync"
      return # Abort the rake task`
    end

    synced_files = BoxAdapter.sync_folder_by_name("LP Portal")
    
    puts "Done syncing file list"
    puts "---------------------------"
  
    
    # Build a hash in the form: id => file
    synced_file_hash = {}
    synced_files.each do |f|
      synced_file_hash[f.id] = f
    end
    
    # Build a list of the file ids
    extant_box_ids = BoxDocument.all.pluck(:box_file_id)
    puts "extant: #{extant_box_ids}"
    synced_box_ids = synced_files.map(&:id)
    
    created_box_ids = synced_box_ids - extant_box_ids
    destroyed_box_ids = extant_box_ids - synced_box_ids
    
    puts "synced: #{synced_box_ids}"
    puts "created: #{created_box_ids}"
    puts "destroyed: #{destroyed_box_ids}"
    
    created_box_ids.each do |id|
      
      f = synced_file_hash[id]
      
      categorizer = Categorizer.new(f)

      category_id = categorizer.category_id
      
      year = categorizer.year
      month = categorizer.month
      quarter = categorizer.quarter
      fund = categorizer.fund
      fund_tag = categorizer.fund_tag
      visibility_tag = categorizer.visibility_tag
      entity_name = (categorizer.entity_name if visibility_tag == "entity")

      puts "fund #{fund.class} #{fund}"
      puts "fund_tag #{fund_tag.class} #{fund_tag}"
      puts "visibility_tag #{visibility_tag.class} #{visibility_tag}"
      
      download_url = f.download_url
      box_view_id = BoxViewClient.convert_document(download_url)
      
      box_document = BoxDocument.new({
        box_file_id: f.id,
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
        box_view_id: box_view_id,
        etag: f.etag
      })
      
      puts "Saving BoxDocument for #{f.name}"
      box_document.save
      
      
    end
    
    destroyed_box_ids.each do |id|
      puts "Deleting box document: " + id
      BoxDocument.find_by(box_file_id: id).destroy
    end
    
    SyncEntry.record_sync_end(synced_box_ids.length, created_box_ids.length, destroyed_box_ids.length)

    
  end

end
