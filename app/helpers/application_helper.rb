module ApplicationHelper
  
  def post_form_button(text, url, name, value, options={})
    html = render partial: "common/post_form_button", locals: { url: url, name: name, value: value, text: text }.merge(options)
    return raw html
  end
  
  def current_user
    controller.current_user
  end
  
end
