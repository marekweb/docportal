class DocumentListController < ApplicationController

  before_action :restrict_to_user

  def index
    redirect_to '/list' if current_user
  end

  def document_list

    @show_admin = current_user.admin?

    @notifications = BoxDocument.all.order(:upload_date).limit(6)
    @notification_count = @notifications.count

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

  end

end