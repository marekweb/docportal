class DocumentListController < ApplicationController

  before_action :restrict_to_user

  def index
    redirect_to '/list' if current_user
  end
  
  def special_category_names
    {
      "all" => "All",
      "other" => "Other Documents",
      "advisor" => "Other Advisory Documents"
    }
  end
  
  def sidebar_entries
    ["all", 0, 1, 2, 3, "divider", 4, 5, 6, "other", "divider", 7, 8, "advisor"].map do |i|
      puts i
      name = if i == "divider" then nil elsif special_category_names.has_key?(i) then special_category_names[i] else Categorizer::Categories[i].pluralize end
      OpenStruct.new(slug: i, name: name)
    end
  end

  def document_list

    @show_admin = current_user.admin?
    @documents = current_user.visible_documents

    @show_advisor_category = @documents.where(visibility_tag: "advisor", visible_name: true).any?
    @show_other_category = @documents.where(visible_name: true).where.not(visibility_tag: "advisor").any?

    @notifications = current_user.visible_documents.order(:upload_date).limit(6)
    @notification_count = @notifications.count
    

    if params[:category].present? && !%w(all other advisor).include?(params[:category])
      category = params[:category].to_i
      @documents = @documents.where(category: category)
      @category_name = Categorizer::Categories[category]
      @category_string = params[:category]
    elsif params[:category] == "advisor"
      #category = "advisor"
      @category_string = "advisor"
      @category_name = special_category_names["advisor"]
      @documents = @documents.where(visibility_tag: "advisor", category: nil)
    elsif params[:category] == "other"
      @category_string = "other"
      @category_name = special_category_names["other"]
      @documents = @documents.where(category: nil).where.not(visibility_tag: "advisor")
    else
      @category_string = "all"
      @category_name = "All"
    end

    if params[:year].present?
      @year_string = params[:year]
      year = params[:year].to_i
      begin # TODO Does this need to be in a block?
        @documents = @documents.where(year: year)
      end
    else
      @year_string = "all"
    end

    # Keep a list of the possible years
    # TODO this could be improved by caching it, similar to caching the max fund
    @years = BoxDocument.where('year IS NOT NULL').select("DISTINCT year").map(&:year).sort.reverse

    @sidebar_entries = sidebar_entries

  end

end