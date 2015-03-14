class BoxAccess < ActiveRecord::Base
    
    def needs_refresh?
        last_refresh <= 1.hour.ago
    end
    
end
