class DocumentFilter
  
  def self.find_documents_visible_to_user(user)
    fund_memberships = user.fund_memberships
    
    # fund_membership is an array of items in the form of [fund:integer, role:string]
    
    documents = BoxDocument.none
    
    fund_memberships.each do |fm|
      if fm.role == "lp-main"
        documents.merge BoxDocument.where(fund: f.fund, visibility_tag: "lps")
        documents.merge BoxDocument.where(fund: f.fund, visibility_tag: "entities", entity_name: user.entity.name.lowercase)
        visibility_tag = "lp"
        fund_tag = "main"
      elsif fm.role == "lp-parallel"
        visibility_tag = "lp"
        fund_tag = "parallel"
      elsif fm.role == "advisor"
        visibility_tag = "advisor"
        fund_tag = nil
      else
        visibility_tag = nil
        fund_tag = nil
      end
      
      if visibility_tag.present?
        documents.merge BoxDocument.where(fund: fm.fund, visibility_tag: visibility_tag)
      end

    end
        

    
    entity_documents = BoxDocument.where(entity_name: user.entity.name.downcase).where(fund: fund)
    
    #lp_documents = BoxDocument.where(fund
    
    # fund_memberships.each do |fm|
    #   BoxDocument.where(fund_id: fm.fund, visibility_tag: fm.role)
    # end
    
  end
  
end