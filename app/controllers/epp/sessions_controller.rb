class Epp::SessionsController < ApplicationController
  include Epp::Common

  private

  def hello
    render 'greeting'
  end

  def login
    @epp_user = EppUser.find_by(login_params)

    if @epp_user.try(:active)
      epp_session[:epp_user_id] = @epp_user.id
      render 'login_success'
    else
      response.headers['X-EPP-Returncode'] = '2200'
      render 'login_fail'
    end
  end

  def logout
    epp_session[:epp_user_id] = nil
    response.headers['X-EPP-Returncode'] = '1500'
    render 'logout'
  end

  ### HELPER METHODS ###

  def login_params
    ph = params_hash['epp']['command']['login']
    { username: ph[:clID], password: ph[:pw] }
  end
end
