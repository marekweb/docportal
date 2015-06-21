class BoxAccess < ActiveRecord::Base
    
    def needs_refresh?
        true# last_refresh.nil? || last_refresh <= 1.hour.ago
    end
    
end
