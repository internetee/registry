class Epp::SessionsController < ApplicationController
  include Epp::Common
  include Epp::SessionsHelper

  private
  def hello
    render 'greeting'
  end

  def login
    @epp_user = EppUser.find_by(login_params)

    if @epp_user.try(:active)
      render 'login_success'
    else
      response.headers['X-EPP-Returncode'] = '2200'
      render 'login_fail'
    end
  end

  def logout
    response.headers['X-EPP-Returncode'] = '1500'
    render 'logout'
  end
end
