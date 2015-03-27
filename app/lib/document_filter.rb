class DocumentFilter
  
  def self.find_documents_visible_to_user(user)
    fund_memberships = user.fund_memberships
    
    # fund_membership is an array of items in the form of [fund:integer, role:string]
    document_relations = []
    
    fund_memberships.each do |fm|
      
      fund_tag_condition = if fm.role == "lp-main"
        ["main", nil]
      elsif fm.role == "lp-parallel"
        ["parallel", nil]
      else
        nil
      end
      
      # Get everything in LPs for the given fund, where fund_tag matches the condition
      document_relations << BoxDocument.where(fund: fm.fund, visibility_tag: "lps", fund_tag: fund_tag_condition)
      
      # Get everything for the particular entity also
      document_relations << BoxDocument.where(fund: fm.fund, visibility_tag: "entity", entity_name: user.entity.name.downcase, fund_tag: fund_tag_condition)
      
      if fm.role == "advisor"
        document_relations << BoxDocument.where(fund: fm.fund, visibility_tag: "advisor")
      end
 
    end

    BoxDocument.where.any_of(*document_relations)
    
  end
  
end