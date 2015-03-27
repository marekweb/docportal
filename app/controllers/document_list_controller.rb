class DocumentListController < ApplicationController

  before_action :restrict_to_user

  def index
    redirect_to '/list' if current_user
  end

  def document_list

    @show_admin = current_user.admin?

    @notifications = current_user.visible_documents.order(:upload_date).limit(6)
    @notification_count = @notifications.count
    
    @documents = current_user.visible_documents
    
    @show_advisor_category = @documents.where(visibility_tag: "advisor").any?

    if params[:category].present? && params[:category] != "all" && params[:category] != "advisor"
      category = params[:category]
      @documents = @documents.where(category: category)
      @sidebar_active = category
      @category_string = category
    elsif params[:category] == "advisor"
      category = "advisor"
      @documents = @documents.where(visibility_tag: "advisor")
    else
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

  end

end