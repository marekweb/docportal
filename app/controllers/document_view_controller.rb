class DocumentViewController < ApplicationController

  def view_document
    box_document = BoxDocument.find params[:id]
    document_session_id  = BoxViewClient.box_get_view_session(box_document)

    if document_session_id.present?
      box_document.mark_opened(current_user)
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
      box_document.mark_downloaded(current_user)
      url = "https://view-api.box.com/1/sessions/#{document_session_id}/content"
      redirect_to url
    else
      attempt_reconversion_or_missing_file_message
    end
  end
  
  def attempt_reconversion_or_missing_file_message
    conversion_succeeded = BoxViewClient.do_box_view_conversion_and_update_box_view_id_on_document(box_document)
      if conversion_succeeded
        render_page_reload
      else
        attempt_reconversion_or_missing_file_message
      end
    end
  end
  
  def render_page_reload
    render html: '<p>Locating the file. Please wait...</p> <script>setTimeout(function(){window.location.reload();}, 3000);</script>'.html_safe
  end

  def render_missing_file_message
    render text: "The portal is unable to locate the file for you right now."
  end

end
