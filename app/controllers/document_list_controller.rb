class DocumentListController < ApplicationController

  before_action :restrict_to_user

  def index
    redirect_to '/list' if current_user
  end
  
  def special_category_names
    {
      "all" => "All",
      "other" => "Other Documents",
      "advisor" => "Advisory Other Documents"
    }
  end
  
  def shorter_names_for_categories
    {
      8 => "Advisor Mtg Minutes",
      "advisor" => "Advisory Other"
    }
  end
  
  def sidebar_entries
    ["all", 0, 1, 2, 3, 4, 11, "divider", 5, 6, 7, "other", "divider", 8, 10, "advisor"].map do |i|
      name = if i == "divider" then nil elsif special_category_names.has_key?(i) then special_category_names[i] else Categorizer::Categories[i].pluralize end
      if i == 8 || i == 10
        name = "Advisory #{name}" 
      end
      OpenStruct.new(slug: i, name: name)
    end
  end

  def document_list

    @show_admin = current_user.admin?
    @documents = current_user.visible_documents
    
    box_access = BoxAccess.first
    
    if box_access.general_message_enabled && box_access.general_message.present?
      @general_message = box_access.general_message
    end

    # TODO
    # Improve the new document notification lookup
    @notifications = @documents.joins(:document_view).where('document_views.first_opened_at = NULL').limit(6) #@documents.joins(:document_view).where('document_views.user_id' => current_user.id).where('document_views.first_opened_at = NULL OR document_views.first_downloaded_at = NULL').reorder(upload_date: :asc).limit(6)

    @notification_count = @notifications.count

    if params[:category].present? && !%w(all other advisor).include?(params[:category])
      category = params[:category].to_i
      @documents = @documents.where(category: category)
      @category_name = Categorizer::Categories[category]
      @category_string = params[:category]
    elsif params[:category] == "advisor"
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
    
    # For non-advisors, remove the advisor-only categories
    # TODO this could better be replacd by showing categories only by the number of files
    if !current_user.admin? && !current_user.advisor?
      categories_only_for_advisors = [8, 10, "advisor"]
      @sidebar_entries = @sidebar_entries.reject{ |e| categories_only_for_advisors.include? e.slug }
    end
    
    if params[:as_json]
      render json: {
        sidebar: @sidebar_entries,
        documents: @documents
      }
      return
    end

  end

end