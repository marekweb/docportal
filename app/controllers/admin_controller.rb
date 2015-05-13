class AdminController < ApplicationController
  
  before_action :prepare_navbar
  before_action :restrict_to_admin
  
  def create_user
    @user = User.new(params.require(:user).permit(:email, :first_name, :last_name))
    
    if params[:entity_id].present?
      @user.entities << Entity.find(params[:entity_id])
    end
    
    @user.generate_activation_token
    
    # Set the password just to be able to save the user
    @user.password = @user.password_confirmation = @user.activation_token
    
    @user.save
    
    if @user.errors.any?
      flash[:notice] = @user.errors.full_messages.to_sentence.capitalize + '.'
      puts "ERROR " +flash[:notice]
    else
      # User was created. 
      # Immediately send the activation mail?
      
      # Commented out, because the email is not sent right away
      #MandrillMailer.send_activation @user
    end

    
    redirect_to "/users"
  end
  
  def update_user
    
    user_params = params.require(:user).permit(:email, :first_name, :last_name)
    user = User.find(params.require(:id))
    user.update_attributes(user_params)
    
    user.save
    
    if user.errors.any?
      return render json: { status: false, message: user.errors.full_messages.to_sentence.capitalize }
    else
      return render json: { status: true, message: "Saved details for #{user.display_name}" }
    end
    
  end
  
  def sync
    # Box access and sync information
    @last_syncs = SyncEntry.order(:started_at).last(10).reverse
    @sync = SyncEntry.order(:id).last
    @box_access = BoxAccess.first

  end
  
  def users
    enabled_users = User.order(:last_name).where(enabled: true)
    disabled_users = User.order(:last_name).where(enabled: false)
    @users = enabled_users + disabled_users
    @entities_for_select =  [OpenStruct.new({id:nil, name:'Add Entity'.html_safe})] + Entity.all.order(:name)
  end
  
  def entities
    @entities = Entity.all.order(:name)
    @number_of_funds = 3
    
    @fund_roles = ['&mdash;'.html_safe, 'LP Main', 'LP Parallel', 'Advisor'].zip([nil, 'lp-main', 'lp-parallel', 'advisor'])
  end
  
  def delete_entity
    id = params.require(:id)
    entity = Entity.find(id)
    entity.destroy
    
    User.where(entity_id: id).update_all(entity_id: nil)
    
    redirect_to "/entities"
  end
  
  def create_entity
    name = params[:name].strip
    return redirect_to "/entities" if name.length == 0
    return redirect_to "/entities" if Entity.exists?(name: name)
    entity = Entity.create({name: name})
    entity.save
    redirect_to "/entities"
  end
  
  def update_entity

    entity = Entity.find(params[:id])

    params[:fund].each do |f, role|
      if role.nil? || role.empty?
        fm = FundMembership.find_by(entity_id: entity.id, fund: f)
        fm.destroy if fm.present?
      elsif %w(advisor lp-main lp-parallel).include? role
        fm = FundMembership.find_by(entity_id: entity.id, fund: f) #TODO incomplete
        if fm.present?
          fm.role = role
          fm.save
        else
          fm = FundMembership.new(entity_id: entity.id, fund: f, role: role)
          fm.save
        end
      end
    end
    
    entity.update_attributes(params.permit(:name))
    entity.save
    
    if entity.errors.any?
      return render json: { status: false, message: entity.errors.full_messages.to_sentence.capitalize }
    else
      return render json: { status: true, message: "Saved details for #{entity.name}" }
    end
    
  end
  
  def add_user_entity
    user = User.find(params[:user_id])
    entity = Entity.find(params[:entity_id])
    user.entities << entity
    user.save
    render json: {}
  end
  
  def remove_user_entity
    user = User.find(params[:user_id])
    entity = Entity.find(params[:entity_id])
    user.entities.delete(entity)
    render json: {}
  end
  
  def set_notifications
    value = params.require(:notifications_enabled)
    box_access = BoxAccess.first
    box_access.notifications_enabled = value
    box_access.save
    redirect_to "/messaging"
  end
  
  def toggle_user_enabled
    id = params[:id]
    User.find(id).try do |u|
      u.toggle :enabled
      u.save
    end
    redirect_to :back
  end
  
  def send_activation
    id = params[:id]
    User.find(id).try do |u|
      # If the user has already signed in then activation should not happen again
      if u.current_sign_in_at.nil?
        MandrillMailer.send_activation(u)
      end
    end
    redirect_to '/users'
  end
  
  def messaging
    @users = User.all
    box_access = BoxAccess.first
    @general_message = box_access.general_message
    @general_message_enabled = box_access.general_message_enabled
    @notifications_enabled = box_access.notifications_enabled
    
    @dates = 14.days.ago.to_date..Date.today
    
    @dates = @dates.map do |d|
      files = User.last.visible_documents.where(upload_date: d)
      OpenStruct.new({date: d, files: files})
    end
    
  end
  
  def set_messaging
    message = params[:general_message]
    enabled = params[:general_message_enabled]
    throw "enabled is #{enabled}"
    box_access = BoxAccess.first
    box_access.general_message = message
    box_access.general_message_enabled = enabled
    box_access.save
    
    redirect_to '/messaging'
  end
    
  private
    
  def restrict_to_admin
    if !current_user.try(:admin?)
      flash[:notice] = "Please log in"
      redirect_to "/login"
    end
  end
  
end
