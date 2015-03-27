class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  force_ssl

  def prepare_navbar
    @notification_count = 0
    @notifications = []
  end

  def current_user
    return @current_user if @current_user.present?
    return nil if session[:user_id].nil?

    @current_user = User.find(session[:user_id])
  end

  def restrict_to_user
    if current_user.nil?
      flash[:notice] = 'Please log in to continue.'
      flash[:redirect] = request.path
      redirect_to '/login'
    end
  end

  def restrict_to_admin
    unless current_user.try(:admin?)
      flash[:notice] = 'Please log in as an administrator'
      flash[:redirect] = request.path
      redirect_to '/login'
    end
  end
end
