class DocumentViewController < ApplicationController
  
  def view_document
    box_document = BoxDocument.find params[:id]
    document_session_id  = BoxViewClient.box_get_view_session(box_document)
    
    if document_session_id.present?
      url = "https://view-api.box.com/1/sessions/#{document_session_id}/view"
      redirect_to url
    else
      render_missing_file_message
    end
  end
  
  def download_document
    box_document = BoxDocument.find params[:id]
    document_session_id  = BoxViewClient.box_get_view_session(box_document)
    
    if document_session_id.present?
      url = "https://view-api.box.com/1/sessions/#{document_session_id}/content"
      redirect_to url
    else
      render_missing_file_message
    end
  end
  
  def render_missing_file_message
    render text: "The portal is unable to locate the file for you right now."  
  end

end
