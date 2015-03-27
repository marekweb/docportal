class BoxDocument < ActiveRecord::Base
  
  def full_file_name
    File.basename(name, File.extname(name)).tr('_', ' ').titleize
  end
  
  def display_title
    

    
    if category.nil?
      if visible_name?
        title = full_file_name
      else
        title = "Document"
      end
    else
      title = Categorizer::Categories[category]
    end
    
    # Shows any/all of quarter, month and year
    if display_date.present?
      title += " " + display_date
    end
    
    extra_info = []
    
    if entity_name.present?
      extra_info << normalized_entity_name
    end
    
    if fund.present?
      extra_info << "Fund #{fund}"
    end
    
    if extra_info.any?
      title += " (" + extra_info.join(", ") + ")"
    end
    
    title
  end
  
  def normalized_entity_name
    Entity.normalize_name(entity_name)
  end
  
  def display_date
    [display_quarter, display_month, display_year].compact.join(" ")
  end
  
  def display_quarter
    "Q#{quarter}" if quarter.present?
  end
  
  def display_year
    "#{year}" if year.present?
  end
  
  def display_month
    Date::MONTHNAMES[month] if month.present?
  end
  
  def download_link
    "/download/#{id}"
  end
  
  def view_link
    "/view/#{id}"
  end
  
  def category_class
    "cat#{(category || 0)}"
  end
  
  def debug_details
    "visibility=#{visibility_tag} fund=#{fund} fund_tag=#{fund_tag} category=#{category} entity=#{entity_name}"
  end
  
  def self.all_visible_to_user(user)
    
    fund_memberships = user.entity.fund_memberships
    
    BoxDocument.where
    
  end
  
end
