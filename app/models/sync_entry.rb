class SyncEntry < ActiveRecord::Base
  
  def self.last_incomplete_sync
    self.where(completed_at: nil).last
  end
  
  def self.record_sync_start
    sync_entry = self.new
    sync_entry.started_at = DateTime.now
    sync_entry.save
  end
  
  def self.record_sync_end(total_files=0, added_files=0, removed_files=0)
    sync_entry = self.last_incomplete_sync
    if sync_entry.present?
      sync_entry.completed_at = DateTime.now
      sync_entry.total_files = total_files
      sync_entry.added_files = added_files
      sync_entry.removed_files = removed_files
      sync_entry.save
      puts "Saved sync_entry"
    else
      puts "Did not find a sync entry so did not save"
    end
    
  end
  
  def self.record_sync_failure(message)
    sync_entry = self.last_incomplete_sync
    sync_entry.failure = message
  end
  
end