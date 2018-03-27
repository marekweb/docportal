class DocumentViewController < ApplicationController

  # def view_document
  #   box_document = BoxDocument.find params[:id]
  #   document_session_id  = BoxViewClient.box_get_view_session(box_document)

  #   if document_session_id.present?
  #     box_document.mark_opened(current_user)
  #     url = "https://view-api.box.com/1/sessions/#{document_session_id}/view"
  #     redirect_to url
  #   else
  #     attempt_reconversion_or_missing_file_message(box_document)
  #   end
  # end
  
  def view_document2
    # box_access = BoxAccess.first
    box_document = BoxDocument.find(params[:id])

    embed_url = NewBoxViewClient.box_get_embed_link2(box_document.box_file_id)
    puts embed_url
    redirect_to embed_url['url'] + '?showDownload=true'
  end
  
  def download_document2
   box_access = BoxAccess.first
    box_document = BoxDocument.find(params[:id])
    
    download_url = NewBoxViewClient.box_get_download_link2(box_document.box_file_id)
    redirect_to download_url
  end

  # def download_document
  #   box_document = BoxDocument.find params[:id]
  #   document_session_id  = BoxViewClient.box_get_view_session(box_document)

  #   if document_session_id.present?
  #     box_document.mark_downloaded(current_user)
  #     url = "https://view-api.box.com/1/sessions/#{document_session_id}/content"
  #     redirect_to url
  #   else
  #     attempt_reconversion_or_missing_file_message(box_document)
  #   end
  # end
  
  # def attempt_reconversion_or_missing_file_message(box_document)
  #   conversion_succeeded = BoxViewClient.do_box_view_conversion_and_update_box_view_id_on_document(box_document)
  #   if conversion_succeeded
  #     render_page_reload
  #   else
  #     render_missing_file_message
  #   end
  # end
  
  def render_page_reload
    render html: '<p>Locating the file. Please wait...</p> <script>setTimeout(function(){window.location.reload();}, 3000);</script>'.html_safe
  end

  def render_missing_file_message
    render text: "The portal is unable to locate the file for you right now."
  end

end
