class DocumentListController < ApplicationController

  before_action :restrict_to_user

  def index
    redirect_to '/list' if current_user
  end

  def document_list

    @show_admin = current_user.admin?

    @notification_count = 2
    @notifications = BoxDocument.all.order(:upload_date).limit(2)

    if params[:category].present? && params[:category] != "all"
      category = params[:category]
      @documents = BoxDocument.where(category: category)
      @sidebar_active = category
      @category_string = category
    else
      @documents = BoxDocument.all
      @category_string = "all"
    end

    if params[:year].present?
      @year_string = params[:year]
      year = params[:year].to_i
      begin
        @documents = @documents.where(year: year)
      end
    else
      @year_string = "all"
    end

    @years = BoxDocument.where('year IS NOT NULL').select("DISTINCT year").map(&:year).sort.reverse
    @sidebar = Categorizer::Categories

    # @sidebar = [
    #   'Capital Calls & Dist.',
    #   'Account Statements',
    #   'Financial Statements',
    #   'LP Reports',
    #   'Legal Docs',
    #   'Tax & FATCA'
    #   ]


    #   @category_groupings = [
    #   'Capital Calls & Dist.',
    #   'Account Statements',
    #   'Financial Statements',
    #   'LP Reports',
    #   'Legal Docs',
    #   'Tax & FATCA'
    #   ]
    
    #@fund_roles = DocumentFilter.find_documents_visible_to_user current_user

  end

end