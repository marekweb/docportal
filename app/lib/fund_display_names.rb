class FundDisplayNames
  
  NamesByFundNumber = {
    1 => "MSU08",
    2 => "RV11",
    3 => "RV14",
    4 => "RV17",
    5 => "RVOMTL17" 
  }

  def self.get_display_name_for_fund_number(fund_number)
    display_name = NamesByFundNumber[fund_number]
    
    if display_name
      return display_name
    end
    
    return "Fund #{fund_number}"
  end

end