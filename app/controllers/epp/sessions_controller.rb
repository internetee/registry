class Epp::SessionsController < ApplicationController
  protect_from_forgery with: :null_session

  def proxy
    send(params[:command])
  end

  private
  def hello
    render 'greeting'
  end

  def login
    login_params = parsed_frame.css('epp command login')
    username = login_params.css('clID').text
    password = login_params.css('pw').text

    @epp_user = EppUser.find_by(username: username, password: password)

    if @epp_user.try(:active)
      render 'login_success'
    else
      response.headers['X-EPP-Returncode'] = '2200'
      render 'login_fail'
    end
  end

  def parsed_frame
    Nokogiri::XML(params[:frame]).remove_namespaces!
  end
end
