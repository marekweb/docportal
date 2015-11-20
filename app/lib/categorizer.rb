class Categorizer

  Categories = ["Quarterly Report", "Capital Call", "Distribution", "Financial Statement", "LPA", "Account Statement", "Tax Document", "FATCA Document", "Meeting Minutes", "Subscription Agreement", "Presentations", "General Document"]
  CategoriesWithVisibleNames = [11]

  FundTags = ["Main", "Parallel"].map(&:downcase)
  VisibilityTags = ["LPs", "Advisors", "Entities"].map(&:downcase).map(&:singularize)

  def self.fetch_existing_box_documents(file_objects)
    id_list = file_objects.map(&:id)
    BoxDocument.find(id_list)
  end

  def initialize(box_file)
    @path = box_file.path_collection['entries'].map{ |e| e["name"] }
  end
  
  def full_path
    @path.join('/')  
  end
  
  def year
    @path.find do |p|
      # Pattern for detecting a year: "20XX"
      return p.to_i if /\A20\d\d\Z/.match p.strip
    end

    return nil
  end

  def visible_name?
    contains_wildcard = @path.any? do |p|
      p.downcase.include? 'wildcard'
    end

    category_has_visible_names = CategoriesWithVisibleNames.include?(category_id)

    contains_wildcard || category_has_visible_names
  end

  def entity_name
    # Entity names are taken to be a folder name directly below the "Entities" folder
    entities_folder_index = @path.find_index { |p| p.downcase == "entities" }
    # Skip if there is no "Entities" folder in the path
    return nil if entities_folder_index.nil?

    # Skip if the "Entities" folder is the last element in the path
    return nil if entities_folder_index == @path.length - 1

    # Return the name of the folder directly following "Entities"
    entity_name = @path[entities_folder_index + 1].downcase

    entity_name
  end

  def month
    @path.each do |p|
      p = p.capitalize
      # Pattern for detecting months: case insensitive full names of months
      Date::MONTHNAMES.each_with_index do |m, i|
        return i if p == m
      end
    end

    return nil
  end

  def quarter
    @path.each do |p|
      # Pattern for matching quarters, case insensitive: Q1, Q2, Q3, Q4
      return p[1].to_i if /\A[Qq]\s?[1-4]\Z/.match(p)
    end

    return nil
  end

  def fund
    @path.each do |p|
      # Pattern for matching fund, case insentitive: "Fund X" where X is a digit
      return p[5].to_i if /\A[Ff]und [1-9]\Z/.match(p)
    end

    return nil
  end

  def fund_tag
    @path.each do |p|
      p = p.downcase
      return p if FundTags.index(p) != nil
    end

    return nil
  end

  def visibility_tag
    @path.each do |p|
      p = p.downcase.singularize
      return p if VisibilityTags.index(p) != nil
    end

    return nil
  end

  def category_id

    @path.each do |p|
      p = p.downcase.singularize
      i = Categories.map(&:downcase).map(&:singularize).index(p)
      return i if i.present?
    end

    return nil

  end

  def self.extract_filing_date(file)
    warn "Categorizer.extract_filing_date is deprecated"

    path = self.extract_path_entries(file)
    filing_year = nil
    filing_month = nil

    path.each do |p|
      filing_year = p if /^20\d{2}$/.match p
      filing_month = p if Date::MONTHNAMES.include? p
    end

    if filing_year.present? && filing_month.present?
      return filing_year.to_i, Date::MONTHNAMES.index(filing_month)
    else
      return nil, nil
    end

  end

  def self.extract_path_entries(file)
    warn "Categorizer.extract_path_entries is deprecated"
    file.path_collection.entries.map{ |e| e["name"] }
  end


end
