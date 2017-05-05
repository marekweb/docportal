module DocumentListHelper
  def fund_display_name(fund_number)
    display_name = FundDisplayNames.get_display_name_for_fund_number(fund_number)
    
    if display_name.present?
      return display_name
    end
    
    return "Fund #{fund_number}"
  end
end