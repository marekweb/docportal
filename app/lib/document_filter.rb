class DocumentFilter

  def self.find_documents_visible_to_user(user, base_relation=nil)
    fund_memberships = user.fund_memberships

    # fund_membership is an array of items in the form of [fund:integer, role:string]
    document_conditions = []

    fund_memberships.each do |fm|

      fund_tag_condition = if fm.role == "lp-main"
        ["main", nil]
      elsif fm.role == "lp-parallel"
        ["parallel", nil]
      elsif fm.role == "advisor"
        ["main", "parallel", nil]
      end

      # Get everything in LPs for the given fund, where fund_tag matches the condition
      document_conditions << {fund: fm.fund, visibility_tag: "lp", fund_tag: fund_tag_condition}

      # Get everything for the particular entity also.
      document_conditions << {fund: fm.fund, visibility_tag: "entity", entity_name: fm.entity.name.downcase, fund_tag: fund_tag_condition}

      if fm.role == "advisor"
        document_conditions << {fund: fm.fund, visibility_tag: "advisor"}
      end

    end

    # A user may have zero entities. In this case they simply have no documents.
    return BoxDocument.none if document_conditions.empty?

    if base_relation == nil
      base_relation = BoxDocument
    end

    results = base_relation.where.any_of(*document_conditions)

    apply_order(results)
  end

  def self.find_documents_visible_to_admin
    apply_order(BoxDocument.all)
  end

  private

  def self.apply_order(relation)
    relation.order('coalesce(year, -1) desc').order('coalesce(quarter, -1) desc').order('coalesce(month, -1) desc').order(upload_date: :desc)
  end

end