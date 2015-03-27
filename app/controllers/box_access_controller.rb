class BoxAccessController < ApplicationController
  before_action :restrict_to_admin

  # Action that sends the user to the Box authentication
  def box_login
    box_session = BoxAdapter.create_session
    redirect_url = box_session.authorize_url('https://' + ENV['HOSTNAME']  + '/box_redirect')

    redirect_to redirect_url
  end

  # Action for the redirect destination URL, to which Box OAuth redirects
  def box_redirect
    box_session = BoxAdapter.create_session
    code = params.require :code

    @token = access_token = box_session.get_access_token(code)
    box_access = BoxAccess.first
    if box_access.nil?
      box_access = BoxAccess.new
    end

    box_access.token = access_token.token
    box_access.refresh_token = access_token.refresh_token
    box_access.last_refresh = DateTime.now

    box_client = BoxAdapter.create_client_from_box_access(box_access)
    box_access.user_email = box_client.me.login

    box_access.save

    @box_access = box_access
    if flash[:redirect]
      return redirect_to flash[:redirect]
    end

    redirect_to '/users'
  end
end
