class DocumentListController < ApplicationController

  before_action :restrict_to_user

  def index
    redirect_to '/list' if current_user
  end

  def document_list

    @show_admin = current_user.admin?
    
    @documents = current_user.visible_documents

    @show_advisor_category = @documents.where(visibility_tag: "advisor", visible_name: true).any?
    @show_other_category = @documents.where(visible_name: true).where.not(visibility_tag: "advisor").any?

    @notifications = current_user.visible_documents.order(:upload_date).limit(6)
    @notification_count = @notifications.count
    
    
    if params[:category].present? && !%w(all other advisor).include?(params[:category])
      category = params[:category]
      @documents = @documents.where(category: category)
      @sidebar_active = category
      @category_string = category
    elsif params[:category] == "advisor"
      category = "advisor"
      @documents = @documents.where(visibility_tag: "advisor", visible_name: true)
    elsif params[:category] == "other"
      category = "other"
      @category = @documents.where(visible_name: true).where.not(visibility_tag: "advisor")
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

    # Keep a list of the possible years
    # TODO this could be improved by caching it, similar to caching the max fund
    @years = BoxDocument.where('year IS NOT NULL').select("DISTINCT year").map(&:year).sort.reverse
    @sidebar = Categorizer::Categories

  end

end