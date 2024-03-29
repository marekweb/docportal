Rails.application.routes.draw do
  
  root 'document_list#index'
  
  get 'login' => 'auth#login_page'
  post 'login' => 'auth#login'
  get 'logout' => 'auth#logout'
  
  get 'reset_password' => 'auth#reset_password_page'
  post 'reset_password' => 'auth#reset_password'
  
  get 'select_password' => 'auth#select_password_page'
  post 'select_password' => 'auth#select_password'
  get 'activate_password' => 'auth#activate_password_page'
  post 'activate_password' => 'auth#activate_password'
  
  get 'admin', to: redirect('/users')

  post 'toggle_user_enabled' => 'admin#toggle_user_enabled'
  post 'delete_user' => 'admin#delete_user'
  post 'send_activation' => 'admin#send_activation'
  post 'set_notifications' => 'admin#set_notifications'
  
  get "list" => "document_list#document_list"
  get "list/all/all" => "document_list#document_list"
  get "list/all/:category" => "document_list#document_list"
  get "list/:year/:category" => "document_list#document_list"
  
  get "view/:id" => "document_view#view_document"
  get "view2/:id" => "document_view#view_document2"

  get "download/:id" => "document_view#download_document"
  get "download2/:id" => "document_view#download_document2"
    
  get 'box_login' => 'box_access#box_login'
  get 'box_redirect' => 'box_access#box_redirect'
  
  get 'sync' => 'admin#sync'
  get 'users' => 'admin#users'
  get 'entities' => 'admin#entities'
  get 'messaging' => 'admin#messaging'
  
  post 'set_messaging' => 'admin#set_messaging'
  
  post "create_user" => "admin#create_user"
  post "update_user" => "admin#update_user"
  
  post "delete_entity" => "admin#delete_entity"
  post "update_entity" => "admin#update_entity"
  post "create_entity" => "admin#create_entity"
  
  post 'add_user_entity' => 'admin#add_user_entity'
  post 'remove_user_entity' => 'admin#remove_user_entity'
  
end
