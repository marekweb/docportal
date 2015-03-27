class BoxAccess < ActiveRecord::Base
  def needs_refresh?
    last_refresh.nil? || last_refresh <= 1.hour.ago
  end
end
