Rails.application.routes.draw do
  
  root 'document_list#index'
  
  get 'login' => 'auth#login_page'
  post 'login' => 'auth#login'
  get 'logout' => 'auth#logout'
  
  get 'reset_password' => 'auth#reset_password_page'
  post 'reset_password' => 'auth#reset_password'
  
  get 'select_password' => 'auth#select_password_page'
  post 'select_password' => 'auth#select_password'
  
  get 'admin', to: redirect('/users')

  post 'toggle_user_enabled' => 'admin#toggle_user_enabled'
  post 'set_notifications' => 'admin#set_notifications'
  
  get "list" => "document_list#document_list"
  get "list/all/all" => "document_list#document_list"
  get "list/all/:category" => "document_list#document_list"
  get "list/:year/:category" => "document_list#document_list"
  
  get "view/:id" => "document_view#view_document"
  get "download/:id" => "document_view#download_document"
  
  get 'box_login' => 'box_access#box_login'
  get 'box_redirect' => 'box_access#box_redirect'
  
  # get 'box_view_upload' => 'auth#box_view_upload'
  # get 'box_view_documents' => 'auth#box_view_documents'
  # get 'box_view_create_session' => 'auth#box_view_create_session'
  
  # get 'box_sync' => 'auth#box_sync'
  
  #get 'view' => 'auth#view'
  
  # get 'convert' => 'auth#convert'
  
  # get 'adapter' => 'auth#adapter' # not useful
  

  # post 'get_view_session' => 'auth#box_get_view_session'
  
  # get 'doc_viewer' => 'auth#doc_viewer'
  
  get 'sync' => 'admin#sync'
  get 'users' => 'admin#users'
  get 'entities' => 'admin#entities'
  
  post "create_user" => "admin#create_user"
  post "update_user" => "admin#update_user"
  
  post "delete_entity" => "admin#delete_entity"
  post "update_entity" => "admin#update_entity"
  post "create_entity" => "admin#create_entity"
  
end
