class DocumentFilter
  
  def self.find_documents_visible_to_user(user)
    fund_memberships = user.fund_memberships
    
    # fund_membership is an array of items in the form of [fund:integer, role:string]
    document_conditions = []
    
    fund_memberships.each do |fm|
      
      fund_tag_condition = if fm.role == "lp-main"
        ["main", nil]
      elsif fm.role == "lp-parallel"
        ["parallel", nil]
      else
        nil
      end
      
      # Get everything in LPs for the given fund, where fund_tag matches the condition 
      document_conditions << {fund: fm.fund, visibility_tag: "lp", fund_tag: fund_tag_condition}
      
      # Get everything for the particular entity also.
      document_conditions << {fund: fm.fund, visibility_tag: "entity", entity_name: user.entity.name.downcase, fund_tag: fund_tag_condition}
      
      if fm.role == "advisor"
        document_conditions << {fund: fm.fund, visibility_tag: "advisor"}
      end
 
    end
    
    puts "Document Conditions"
    puts document_conditions

    BoxDocument.where.any_of(*document_conditions)
    
  end
  
end