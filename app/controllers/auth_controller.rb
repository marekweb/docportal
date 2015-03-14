class AuthController < ApplicationController
  
  def login_page
    @html_classes = "login"
    @email = params[:email] || flash[:email]
    @redirect = flash[:redirect]
  end
  
  def login
    redirect_param = params[:redirect]

    user = User.find_by(email: params[:email]).try do |u|
      u.authenticate(params[:password])
    end
    
    if !user || !user.enabled
      flash[:email] = params[:email]
      flash[:notice] = "Your credentials are incorrent."
      redirect_to :back
    else
      session[:user_id] = user.id
      redirect_to redirect_param || "/"
    end
  end
  
  def logout
    session.destroy
    redirect_to "/login"
  end
  
  def reset_password_page
    # User enters their email, and this initiates the password reset
  end

  def reset_password
    @email = params[:email]
    u = User.find_by(email: @email)
    if u.present?
      u.reset_password_token = Devise.friendly_token.first(16) 
      u.reset_password_sent_at = DateTime.now
      u.save

      # Trigger email
      # TODO
      
      flash[:notice] = "A message was sent to #{@email} with instructions."
      redirect_to '/'
    else
      flash[:notice] = "No account was found with that email address."
      redirect_to :back
    end
    
  end
  
  def select_password_page
    @token = params[:token]
    return redirect_password_reset_error if @token.nil?

    @user = User.find_by(reset_password_token: @token)
    return redirect_password_reset_error if @user.nil?
    
    # If reset_password_set_at field is set, then check it against the expiry period.
    # If reset_password_set_at field is NOT set, then there's no expiry for this token.
    return redirect_password_reset_error if @user.reset_password_sent_at.present? && @user.reset_password_sent_at >= 24.hours.ago
    
    
  end
  
  
  def select_password
    @token = params[:token]
    return redirect_password_reset_error if @token.nil?
    @user = User.find_by(reset_password_token: @token)
    return redirect_password_reset_error if @user.nil?

    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    @user.reset_password_token = nil
    @user.save
    
    # Allow to login the user directly
    session[:user_id] = @user.id
    redirect_to '/'
    
  end

  def redirect_password_reset_error
      flash[:notice] = "The security link you followed is not valid. If you obtained it by requesting a password reset, please request a new password reset again."
      redirect_to '/login' and return
  end

end
