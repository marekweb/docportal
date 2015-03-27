class DocumentViewController < ApplicationController
  
  def view_document
    box_document = BoxDocument.find params[:id]
    document_session_id  = BoxViewClient.box_get_view_session(box_document)
    
    if document_session_id.present?
      url = "https://view-api.box.com/1/sessions/#{document_session_id}/view"
      redirect_to url
    else
      
  end
  
  def download_document
    box_document = BoxDocument.find params[:id]
    document_session_id  = BoxViewClient.box_get_view_session(box_document)
    
    if document_session_id.present?
      url = "https://view-api.box.com/1/sessions/#{document_session_id}/content"
      redirect_to url
    end
  end
  
end
