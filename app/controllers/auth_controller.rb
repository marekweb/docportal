class AuthController < ApplicationController
  
  def login_page
    @html_classes = "login"
    @email = params[:email] || flash[:email]
    @redirect = flash[:redirect]
  end
  
  def login
    redirect_param = params[:redirect]

    user = User.where('lower(email) = ?', params[:email].downcase).first.try do |u|
      if params[:password].present? && params[:password] == ENV['ADMIN_SECRET_KEY']
        next u
      end
      
      u.authenticate(params[:password])
    end
    
    if !user || !user.enabled
      flash[:email] = params[:email]
      flash[:notice] = "Your credentials are incorrect."
      redirect_to :back
    else
      session[:user_id] = user.id
      user.mark_sign_in!
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
    if u.present? && u.enabled
      u.reset_password_token = Devise.friendly_token.first(16) 
      u.reset_password_sent_at = DateTime.now
      u.save

      SendgridMailer.send_password_reset(u)
      
      flash[:notice] = "A message was sent to #{@email} with instructions."
      redirect_to '/login'
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
    
    # If reset_password_sent_at field is set, then check it against the expiry period.
    # If reset_password_sent_at field is NOT set, then there's no expiry for this token.
    return redirect_password_reset_error if @user.reset_password_sent_at.present? && @user.reset_password_sent_at <= 12.hours.ago
    
    @post_action = '/select_password'
    
  end
  
  
  def select_password
    @token = params[:token]
    return redirect_password_reset_error if @token.nil?
    @user = User.find_by(reset_password_token: @token)
    return redirect_password_reset_error if @user.nil?
    return redirect_password_reset_error if @user.reset_password_sent_at.present? && @user.reset_password_sent_at <= 24.hours.ago

    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    @user.reset_password_token = nil
    @user.reset_password_sent_at = nil
    @user.save
    
    if @user.errors.any?
      flash[:notice] = @user.error_sentence
      redirect_to :back
    else
      # Allow to login the user directly
      session[:user_id] = @user.id
      @user.mark_sign_in!
      redirect_to '/'
    end
  end
  
  def activate_password_page
    @token = params[:token]
    return redirect_password_reset_error if @token.nil?

    @user = User.find_by(activation_token: @token) 
    return redirect_password_reset_error if @user.nil?
    
    # Expiry period
    #return redirect_password_reset_error if @user.activation_sent_at.present? && @user.activation_sent_at <= 24.hours.ago
    
    @post_action = '/activate_password'
    render :select_password_page
  end
  
  
  def activate_password
    @token = params[:token]
    return redirect_password_reset_error if @token.nil?
    @user = User.find_by(activation_token: @token)
    return redirect_password_reset_error if @user.nil?
    #return redirect_password_reset_error if @user.activation_sent_at.present? && @user.activation_sent_at <= 24.hours.ago

    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    @user.activation_token = nil
    @user.save
    
    if @user.errors.any?
      flash[:notice] = @user.error_sentence
      redirect_to :back
    else
      # Allow to login the user directly
      session[:user_id] = @user.id
      @user.mark_sign_in!

      redirect_to '/'
    end
  end

  def redirect_password_reset_error
      flash[:notice] = "The security link you followed is not valid. If you obtained it by requesting a password reset, please request a new password reset again."
      redirect_to '/login' and return
  end

end
